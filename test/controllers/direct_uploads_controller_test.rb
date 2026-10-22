require "test_helper"

class DirectUploadsControllerTest < ActionDispatch::IntegrationTest
  test "without a session nothing reaches the bucket" do
    assert_no_difference "ActiveStorage::Blob.count" do
      post direct_uploads_path, params: { blob: blob_params }, as: :json
    end
    assert_redirected_to new_session_path
  end

  test "a signed-in user gets a signed blob and the URL to upload it to" do
    sign_in_as(users(:one))

    assert_difference "ActiveStorage::Blob.count", 1 do
      post direct_uploads_path, params: { blob: blob_params }, as: :json
    end
    assert_response :success
    body = response.parsed_body
    assert body["signed_id"].present?
    assert body.dig("direct_upload", "url").present?
  end

  test "only images of a reasonable size" do
    sign_in_as(User.create!(email_address: "maria@fsy.com", password: "Consejera1!", participant: participants(:maria)))

    assert_no_difference "ActiveStorage::Blob.count" do
      post direct_uploads_path, params: { blob: blob_params(content_type: "application/pdf") }, as: :json
      assert_response :unprocessable_content
      post direct_uploads_path, params: { blob: blob_params(byte_size: 16.megabytes) }, as: :json
      assert_response :unprocessable_content
    end
  end

  test "full access also uploads a manual's PDF, up to its limit" do
    sign_in_as(users(:one))

    assert_difference "ActiveStorage::Blob.count", 1 do
      post direct_uploads_path, params: { blob: blob_params(content_type: "application/pdf", byte_size: 20.megabytes) }, as: :json
    end
    assert_response :success

    post direct_uploads_path, params: { blob: blob_params(content_type: "application/pdf", byte_size: 26.megabytes) }, as: :json
    assert_response :unprocessable_content
  end

  private
    def blob_params(content_type: "image/jpeg", byte_size: 1234)
      { filename: "foto.jpg", byte_size: byte_size, checksum: Base64.strict_encode64(Digest::MD5.digest("x")), content_type: content_type }
    end
end

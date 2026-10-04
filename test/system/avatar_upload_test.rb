require "application_system_test_case"
require "vips"

class AvatarUploadTest < ApplicationSystemTestCase
  test "la foto se achica en el navegador antes de subirla" do
    photo = Rails.root.join("tmp/foto-grande.jpg")
    Vips::Image.black(4000, 3000).add([ 200, 120, 40 ]).cast(:uchar).jpegsave(photo.to_s)
    joven = participants(:juan)
    sign_in_as(users(:one))

    visit edit_participant_path(joven)
    attach_file "participant_avatar", photo, make_visible: true
    click_on "Actualizar"

    assert_text "Actualizado exitosamente."
    blob = joven.reload.avatar.blob
    image = Vips::Image.new_from_buffer(blob.download, "")
    assert_equal [ 1600, 1200 ], [ image.width, image.height ]
    assert_equal "image/jpeg", blob.content_type
  ensure
    FileUtils.rm_f(photo)
  end
end

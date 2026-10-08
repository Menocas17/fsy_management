require "application_system_test_case"
require "vips"

class AvatarUploadTest < ApplicationSystemTestCase
  setup do
    @photo = Rails.root.join("tmp/foto-grande-#{SecureRandom.hex(4)}.jpg")
    Vips::Image.black(4000, 3000).add([ 200, 120, 40 ]).cast(:uchar).jpegsave(@photo.to_s)
    @joven = participants(:juan)
    sign_in_as(users(:one))
  end

  teardown { FileUtils.rm_f(@photo) }

  test "la foto se achica en el navegador y se sube directo al almacenamiento antes de guardar" do
    visit edit_participant_path(@joven)
    attach_file "participant_avatar", @photo, make_visible: true

    # Subida directa: el blob existe antes de mandar el formulario, que solo lleva su referencia.
    assert_selector "[data-avatar-preview-target=status]", text: "Foto lista"
    assert_selector "input[type=hidden][name='participant[avatar]']", visible: :hidden
    click_on "Actualizar"

    assert_text "Actualizado exitosamente."
    assert_downscaled_jpeg @joven.reload.avatar.blob
  end

  test "si la subida directa falla, la foto achicada viaja con el formulario como antes" do
    visit edit_participant_path(@joven)
    page.execute_script(<<~JS)
      document.querySelector("[data-controller~=avatar-preview]").dataset.avatarPreviewDirectUploadUrlValue = "/no-existe"
    JS
    attach_file "participant_avatar", @photo, make_visible: true
    click_on "Actualizar"

    assert_text "Actualizado exitosamente."
    assert_no_selector "input[type=hidden][name='participant[avatar]']", visible: :hidden
    assert_downscaled_jpeg @joven.reload.avatar.blob
  end

  private
    def assert_downscaled_jpeg(blob)
      image = Vips::Image.new_from_buffer(blob.download, "")
      assert_equal [ 1600, 1200 ], [ image.width, image.height ]
      assert_equal "image/jpeg", blob.content_type
    end
end

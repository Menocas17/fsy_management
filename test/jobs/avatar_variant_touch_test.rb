require "test_helper"

# La página de la compañía guarda sus listas en caché según el updated_at de cada ficha: cuando la miniatura
# termina de procesarse, la ficha se toca para que la lista deje el enlace provisional y use el definitivo.
class AvatarVariantTouchTest < ActiveJob::TestCase
  test "processing a profile photo's variant touches its participant" do
    participant = participants(:juan)
    participant.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/tiny.png")), filename: "tiny.png")
    participant.update_column(:updated_at, 1.day.ago)

    ActiveStorage::TransformJob.perform_now(participant.avatar.blob, Participant.reflect_on_attachment(:avatar).named_variants[:thumb].transformations)

    assert_in_delta Time.current, participant.reload.updated_at, 1.minute
  end
end

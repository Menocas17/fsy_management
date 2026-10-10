require "test_helper"
require "rake"

# Las listas usan la miniatura chica (:small, 128 px en WebP) y el perfil la de 300 (:thumb). Una foto anterior a
# :small sigue con :thumb hasta que fotos:miniaturas le hace la suya: así nadie la procesa en medio de un pedido.
class AvatarSizesTest < ActionView::TestCase
  include ApplicationHelper
  include ActiveJob::TestHelper

  setup do
    ApplicationHelper::THUMB_URLS.clear
    @participant = participants(:juan)
    @participant.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/tiny.png")), filename: "tiny.png")
    @reflection = Participant.reflect_on_attachment(:avatar)
  end

  test "lists use the thumb until the small one is processed, then the small one" do
    process(:thumb)
    assert_includes participant_thumb_url(reloaded), key_of(:thumb)

    process(:small)
    assert_includes participant_thumb_url(reloaded), key_of(:small)
    assert_includes participant_thumb_url(reloaded, size: :thumb), key_of(:thumb)
  end

  test "the small one is a 128 px WebP square" do
    small = @participant.avatar.variant(:small).processed.image.blob
    small.analyze

    assert_equal "image/webp", small.content_type
    assert_equal [ 128, 128 ], [ small.metadata[:width], small.metadata[:height] ]
  end

  test "fotos:miniaturas enqueues only what is missing" do
    Rails.application.load_tasks unless Rake::Task.task_defined?("fotos:miniaturas")
    process(:thumb)
    process(:preview)

    assert_enqueued_jobs 1, only: ActiveStorage::TransformJob do
      silence_stream($stdout) { Rake::Task["fotos:miniaturas"].execute }
    end
  end

  private
    def process(name)
      ActiveStorage::TransformJob.perform_now(@participant.avatar.blob, @reflection.named_variants[name].transformations)
    end

    def reloaded
      Participant.includes(Participant::AVATAR_PRELOAD).find(@participant.id)
    end

    # La huella de la variante va en su dirección (/rails/active_storage/representations/…/<variation key>/…).
    def key_of(name)
      @participant.avatar.variant(name).variation.key
    end

    def silence_stream(stream)
      old = stream.dup
      stream.reopen(File::NULL)
      yield
    ensure
      stream.reopen(old)
    end
end

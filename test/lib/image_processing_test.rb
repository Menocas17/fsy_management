require "test_helper"

# config/initializers/image_processing.rb: lo que mantiene el procesado de fotos dentro de los 512 MB de Render.
class ImageProcessingTest < ActiveSupport::TestCase
  test "libvips trabaja con un hilo y sin caché" do
    ActiveStorage::Blob # dispara el on_load que lo configura
    assert_equal 1, Vips.concurrency
    assert_equal 0, Vips.cache_max
  end

  test "analizar y sacar variantes comparten un solo turno" do
    [ ActiveStorage::AnalyzeJob, ActiveStorage::TransformJob ].each do |job|
      assert_equal "ActiveStorageImages", job.concurrency_group
      assert_equal 1, job.concurrency_limit
    end
  end
end

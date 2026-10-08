# Las fotos se procesan dentro de Puma (Solid Queue en hilos) y el plan gratis de Render corta a los 512 MB:
# una foto de 12 MP del teléfono sumaba 130-170 MB con libvips de fábrica, que abre un hilo por núcleo de la
# máquina (y Render deja ver muchos) y guarda en caché las operaciones. Con un hilo y sin caché, y de a una
# foto por vez, el pico baja; el navegador además ya la achica antes de subirla (avatar_preview_controller.js).
ActiveSupport.on_load(:active_storage_blob) do
  require "vips"
  Vips.concurrency_set(1)
  Vips.cache_set_max(0)
end

# Analizar una imagen y sacar sus variantes va en la cola images (config/queue.yml), y a lo sumo
# IMAGE_JOB_CONCURRENCY a la vez: 1 en una máquina de 1 GB, donde dos fotos juntas no caben; más en el VPS de
# 8 GB (config/deploy.yml), para que la mañana en que se suben las fotos de todos las miniaturas vayan al día.
Rails.application.config.to_prepare do
  [ ActiveStorage::AnalyzeJob, ActiveStorage::TransformJob ].each do |job|
    job.queue_as :images
    job.limits_concurrency key: "images", group: "ActiveStorageImages", to: ENV.fetch("IMAGE_JOB_CONCURRENCY", 1).to_i
  end
end

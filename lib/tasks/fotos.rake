namespace :fotos do
  # Corre en cada arranque (bin/docker-entrypoint) y solo encola lo que falta, así que no repite trabajo. Los
  # trabajos van a la cola de imágenes, de a IMAGE_JOB_CONCURRENCY (config/initializers/image_processing.rb):
  # en el droplet chico se procesan de una en una, sin quedarse sin memoria.
  desc "Encola las miniaturas que les faltan a las fotos (variantes nuevas de Participant#avatar)"
  task miniaturas: :environment do
    queued = Hash.new(0)
    Participant.unscoped.joins(:avatar_attachment).includes(Participant::AVATAR_PRELOAD).find_each do |participant|
      Participant.attachment_reflections["avatar"].named_variants.each do |name, named|
        next unless named.preprocessed?(participant)

        variant = participant.avatar.variant(name)
        next if variant.key.present? # ya procesada (sin procesar, su llave es nil)

        ActiveStorage::TransformJob.perform_later(participant.avatar.blob, variant.variation.transformations)
        queued[name] += 1
      end
    end
    puts queued.any? ? "Miniaturas encoladas: #{queued.map { |name, count| "#{count} #{name}" }.join(", ")}" : "Todas las fotos tienen sus miniaturas."
  end
end

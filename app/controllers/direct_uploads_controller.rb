# Subida directa de las fotos de perfil: el teléfono sube la foto a R2 sin pasar por Rails, y el formulario
# solo manda la referencia firmada (avatar_preview_controller.js). Ocupa la misma ruta que la de Active
# Storage (config/routes.rb), que de fábrica deja crear archivos en el bucket a cualquiera: aquí hace falta
# haber iniciado sesión, y solo se aceptan imágenes de un tamaño razonable.
class DirectUploadsController < ActiveStorage::DirectUploadsController
  include Authentication

  # Una foto del teléfono pesa unos pocos MB; el navegador además la achica antes de subirla.
  MAX_BYTES = 15.megabytes

  before_action :require_image

  private
    def require_image
      blob = params.require(:blob)
      return if blob[:content_type].to_s.start_with?("image/") && blob[:byte_size].to_i.between?(1, MAX_BYTES)

      render json: { error: "Solo se pueden subir imágenes de hasta #{MAX_BYTES / 1.megabyte} MB" }, status: :unprocessable_content
    end
end

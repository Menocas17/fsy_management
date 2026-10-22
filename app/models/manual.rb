# Los manuales del FSY en PDF (ManualsController, «Manuales» en el menú): el del joven lo ven todos, el de
# líderes todo el staff. Uno por clase; lo sube o reemplaza el acceso total desde la página. Los enlaces a la
# Biblioteca del Evangelio que van con ellos son aparte (ManualLinks).
class Manual < ApplicationRecord
  MAX_BYTES = 25.megabytes

  enum :kind, { joven: 0, lideres: 1 }, validate: true

  has_one_attached :file

  validates :kind, uniqueness: true
  validate :file_is_a_pdf

  TITLES = { "joven" => "Manual del joven", "lideres" => "Manual de líderes" }.freeze

  def self.for(kind)
    find_or_initialize_by(kind: kind)
  end

  # Las clases que ve quien entra: el joven solo el suyo.
  def self.kinds_for(user)
    user&.participant&.joven? ? %w[joven] : kinds.keys
  end

  def title
    TITLES.fetch(kind)
  end

  def available?
    file.attached?
  end

  private
    def file_is_a_pdf
      return unless file.attached?

      errors.add(:file, "debe ser un PDF") unless file.blob.content_type == "application/pdf"
      errors.add(:file, "pesa más de #{MAX_BYTES / 1.megabyte} MB") if file.blob.byte_size > MAX_BYTES
    end
end

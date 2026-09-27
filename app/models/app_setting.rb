# Ajustes del sistema como pares clave/valor, para lo que no pertenece a ningún registro.
class AppSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.[](key)
    find_by(key: key.to_s)&.value
  end

  def self.[]=(key, value)
    find_or_initialize_by(key: key.to_s).update!(value: value)
  end
end

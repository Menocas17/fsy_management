class Inventory < ApplicationRecord
  has_many :items, -> { order(:name) }, class_name: "InventoryItem", dependent: :destroy
  has_many :movements, through: :items

  # Los iconos son de Lucide (app/assets/svg/icons/lucide/outline) y los colores, tokens del tema.
  ICONS = %w[package utensils pill sparkles shirt wrench monitor music heart-pulse boxes].freeze
  COLORS = { "primary" => "Azul", "green" => "Verde", "amber" => "Ámbar", "rose" => "Rojo", "indigo" => "Morado" }.freeze

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :code_prefix, presence: true, uniqueness: { case_sensitive: false },
                          format: { with: /\A[A-Z]{2,5}\z/, message: "usa de 2 a 5 letras mayúsculas" }
  validates :icon, inclusion: { in: ICONS }
  validates :color, inclusion: { in: COLORS.keys }

  before_validation :derive_code_prefix, on: :create

  scope :by_name, -> { order(:name) }

  def low_stock_items
    items.select(&:low?)
  end

  def out_of_stock_items
    items.select(&:out?)
  end

  # El historial y el audit log piden un nombre legible.
  alias_attribute :to_s, :name

  private
    # "Medicinas" → MED; si ya existe, MEDI, MEDIC… hasta encontrar uno libre.
    def derive_code_prefix
      return if code_prefix.present?

      letters = name.to_s.unicode_normalize(:nfd).gsub(/[^A-Za-z]/, "").upcase
      return if letters.blank?

      candidate = letters.first(3)
      candidate = letters.first(candidate.length + 1) while Inventory.exists?(code_prefix: candidate) && candidate.length < 5
      self.code_prefix = candidate
    end
end

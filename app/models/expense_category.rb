# Categoría de gasto. El presupuesto propio es opcional: sin él, sus gastos cuentan solo contra el general.
class ExpenseCategory < ApplicationRecord
  has_many :expenses, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 60 }
  validates :name, uniqueness: { case_sensitive: false }
  validates :budget_cents, numericality: { greater_than: 0 }, allow_nil: true
  validates :icon, inclusion: { in: Appearance::ICONS.keys }
  validates :color, inclusion: { in: Appearance::COLORS.keys }

  scope :by_name, -> { order(Arel.sql("lower(name)")) }

  alias_attribute :to_s, :name
end

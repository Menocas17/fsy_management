class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: "Participant", optional: true

  # logistica is reserved: no logistics feature writes audit entries yet.
  enum :category, { logistica: 0, companias: 1, asignaciones: 2 }

  CATEGORY_LABELS = { "logistica" => "Logística", "companias" => "Compañías", "asignaciones" => "Asignaciones" }.freeze

  validates :actor_name, :action, :category, :summary, presence: true

  scope :recent, -> { order(created_at: :desc, id: :desc) }
  scope :by_category, ->(category) { where(category: category) if categories.key?(category.to_s) }
  scope :search, ->(query) {
    where("actor_name ILIKE :q OR target_name ILIKE :q", q: "%#{sanitize_sql_like(query)}%") if query.present?
  }

  def category_label
    CATEGORY_LABELS.fetch(category, category)
  end
end

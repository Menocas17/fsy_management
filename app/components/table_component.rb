class TableComponent < ViewComponent::Base
  delegate :icon, to: :helpers

  def initialize(participants:, is_staff: false)
    @participants = participants
    @is_staff = is_staff
  end

  def from_path
    @is_staff ? "staff" : "jovenes"
  end

  # El lápiz solo aparece en las fichas que esta persona manda: la cadena la resuelve Authorization.
  def editable?(participant)
    helpers.can_edit_participant?(participant)
  end

  def gender_label(participant)
    Participant::GENDER_LABELS.fetch(participant.gender, participant.gender)
  end

  def company_name(participant)
    participant.company&.name.presence || "—"
  end

  def header_cell_classes
    "pt-5 pb-3 pr-5 text-meta font-bold tracking-[.07em] uppercase text-ink-500"
  end

  def cell_classes
    "py-3.5 pr-5 text-body text-ink-700"
  end

  def row_button_classes
    "w-9 h-9 rounded-control inline-flex items-center justify-center text-ink-500 hover:bg-primary-50 hover:text-primary-600 dark:hover:bg-slate-700 dark:hover:text-slate-200 transition"
  end
end

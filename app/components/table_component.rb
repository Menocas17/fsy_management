class TableComponent < ViewComponent::Base
  delegate :icon, to: :helpers

  def initialize(participants:, is_staff: false)
    @participants = participants
    @is_staff = is_staff
  end

  def from_path
    @is_staff ? "staff" : "jovenes"
  end

  def admin?
    Current.user&.admin_or_staff_manager?
  end

  def gender_label(participant)
    Participant::GENDER_LABELS.fetch(participant.gender, participant.gender)
  end

  def company_name(participant)
    participant.company&.name.presence || "—"
  end

  def header_cell_classes
    "pt-5 pb-3 pr-5 text-[11px] font-bold tracking-[.06em] uppercase text-ink-300 dark:text-slate-500"
  end

  def cell_classes
    "py-3.5 pr-5 text-[13.5px] text-ink-700 dark:text-slate-300"
  end

  def row_button_classes
    "w-9 h-9 rounded-[10px] inline-flex items-center justify-center text-ink-300 hover:bg-primary-50 hover:text-primary-600 dark:text-slate-500 dark:hover:bg-slate-700 dark:hover:text-slate-200 transition"
  end
end

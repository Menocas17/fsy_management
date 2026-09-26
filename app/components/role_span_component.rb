class RoleSpanComponent < ViewComponent::Base
  STYLES = {
    "joven" => "bg-cat-green/15 text-cat-green",
    "consejero" => "bg-cat-amber/20 text-amber-700 dark:text-cat-amber",
    "auxiliar" => "bg-cat-blue/15 text-cat-blue",
    "coordinador" => "bg-cat-indigo/15 text-cat-indigo",
    "director" => "bg-primary-100 text-primary-700 dark:bg-primary-700/40 dark:text-primary-100",
    "logistica" => "bg-cat-rose/15 text-cat-rose",
    "director_logistica" => "bg-cat-amber/20 text-amber-700 dark:text-cat-amber",
    "registrador" => "bg-canvas text-ink-500 dark:bg-slate-700 dark:text-slate-300"
  }.freeze

  def initialize(role:)
    @role = role
  end

  def label
    Participant.role_label(@role) if @role.present?
  end

  def styles
    STYLES.fetch(@role, "bg-canvas text-ink-500 dark:bg-slate-700 dark:text-slate-300")
  end
end

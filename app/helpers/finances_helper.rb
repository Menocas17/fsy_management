module FinancesHelper
  STATUS_CHIPS = {
    "presented" => "bg-cat-blue/15 text-cat-blue-ink",
    "approved" => "bg-cat-amber/20 text-cat-amber-ink",
    "justification_pending" => "bg-cat-amber/20 text-cat-amber-ink",
    "consolidated" => "bg-cat-green/15 text-cat-green-ink",
    "rejected" => "bg-cat-rose/15 text-cat-rose-ink",
    "withdrawn" => "bg-canvas text-ink-500"
  }.freeze
  BAR_TONES = { ok: "bg-cat-green", warn: "bg-cat-amber", over: "bg-cat-rose", none: "bg-primary-500" }.freeze

  # La baldosa de color con el icono de la categoría; «General» (sin categoría) va en gris con una billetera.
  def category_tile(category, size: :md)
    box = size == :sm ? "w-8 h-8 rounded-control" : "w-10 h-10 rounded-tile"
    glyph = size == :sm ? "w-4 h-4" : "w-5 h-5"
    color = category ? Appearance.color_class(category.color) : "bg-ink-500"
    tag.span(icon(category&.icon || "wallet", class: glyph), aria: { hidden: true },
             class: "#{box} shrink-0 text-white flex items-center justify-center #{color}")
  end

  def money(cents, currency = "NIO")
    Money.format(cents, currency)
  end

  def expense_status_chip(expense)
    tag.span(expense.status_label, class: "inline-flex items-center px-2.5 py-1 rounded-full text-[11px] font-bold whitespace-nowrap #{STATUS_CHIPS.fetch(expense.status)}")
  end

  # Monto en su moneda y, si es en dólares, su equivalente en córdobas.
  def expense_amount(expense, cents)
    return "—" if cents.nil?

    text = money(cents, expense.currency)
    expense.usd? ? "#{text} · #{money(expense.to_base(cents))}" : text
  end

  def budget_bar(row)
    width = [ (row.ratio || 0) * 100, 100 ].min.round
    tag.div(class: "h-2 rounded-full bg-canvas overflow-hidden", role: "presentation") do
      tag.div(class: "h-full rounded-full #{BAR_TONES.fetch(row.tone)}", style: "width: #{width}%")
    end
  end
end

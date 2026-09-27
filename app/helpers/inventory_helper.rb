module InventoryHelper
  STATUS_CHIPS = {
    ok:  "text-cat-green-ink bg-cat-green/10",
    low: "text-cat-amber-ink bg-cat-amber/10",
    out: "text-cat-rose-ink bg-cat-rose/10"
  }.freeze

  INVENTORY_COLORS = {
    "primary" => "bg-primary-600", "blue" => "bg-cat-blue", "sky" => "bg-sky-600", "teal" => "bg-cat-teal",
    "green" => "bg-cat-green", "lime" => "bg-lime-600", "amber" => "bg-cat-amber", "orange" => "bg-orange-600",
    "brown" => "bg-amber-800", "rose" => "bg-cat-rose", "pink" => "bg-pink-600", "indigo" => "bg-cat-indigo",
    "violet" => "bg-violet-600", "slate" => "bg-slate-600"
  }.freeze

  def inventory_status_chip(item)
    tag.span(item.status_label,
             class: "inline-flex items-center px-2.5 py-1 rounded-full text-[11px] font-bold #{STATUS_CHIPS.fetch(item.status)}")
  end

  def inventory_tile_class(inventory)
    inventory_color_class(inventory.color)
  end

  def inventory_color_class(color)
    INVENTORY_COLORS.fetch(color.to_s, INVENTORY_COLORS["primary"])
  end

  def inventory_qr_tag(item, size: 132)
    qr_svg_tag(item.qr_payload, label: "Código QR de #{item.code}", size: size)
  end
end

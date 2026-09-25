module InventoryHelper
  STATUS_CHIPS = {
    ok:  "text-cat-green bg-cat-green/10",
    low: "text-cat-amber bg-cat-amber/10",
    out: "text-cat-rose bg-cat-rose/10"
  }.freeze

  INVENTORY_COLORS = {
    "primary" => "bg-primary-600", "green" => "bg-cat-green", "amber" => "bg-cat-amber",
    "rose" => "bg-cat-rose", "indigo" => "bg-cat-indigo"
  }.freeze

  def inventory_status_chip(item)
    tag.span(item.status_label,
             class: "inline-flex items-center px-2.5 py-1 rounded-full text-[11px] font-bold #{STATUS_CHIPS.fetch(item.status)}")
  end

  def inventory_tile_class(inventory)
    INVENTORY_COLORS.fetch(inventory.color, "bg-primary-600")
  end

  def inventory_qr_tag(item, size: 132)
    qr_svg_tag(item.qr_payload, label: "Código QR de #{item.code}", size: size)
  end
end

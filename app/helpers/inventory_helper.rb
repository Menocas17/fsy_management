module InventoryHelper
  STATUS_CHIPS = {
    ok:  "text-cat-green-ink bg-cat-green/10",
    low: "text-cat-amber-ink bg-cat-amber/10",
    out: "text-cat-rose-ink bg-cat-rose/10"
  }.freeze


  def inventory_status_chip(item)
    tag.span(item.status_label,
             class: "inline-flex items-center px-2.5 py-1 rounded-full text-meta font-bold #{STATUS_CHIPS.fetch(item.status)}")
  end

  def inventory_tile_class(inventory)
    inventory_color_class(inventory.color)
  end

  def inventory_color_class(color)
    Appearance.color_class(color)
  end

  def inventory_qr_tag(item, size: 132)
    qr_svg_tag(item.qr_payload, label: "Código QR de #{item.code}", size: size)
  end
end

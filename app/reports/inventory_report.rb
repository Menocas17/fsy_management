# Existencias del inventario, para el conteo físico y para tesorería.
class InventoryReport < ApplicationReport
  filename_stem "inventario"

  def initialize(inventory: nil)
    @inventory = inventory
  end

  private
    def title
      @inventory ? "Inventario · #{@inventory.name}" : "Inventario general"
    end

    def subtitle
      low = items.count { |item| item.low? || item.out? }
      "#{items.size} #{items.size == 1 ? 'artículo' : 'artículos'} · #{low} por agotarse"
    end

    def build(pdf)
      inventories.each_with_index do |inventory, index|
        of_this_one = items.select { |item| item.inventory_id == inventory.id }
        next if of_this_one.empty?

        pdf.start_new_page if index.positive? && pdf.cursor < 120
        section_title(pdf, inventory.name)
        table(pdf, [ "Artículo", "Código", "Existencia", "Mínimo", "Estado", "Ubicación" ],
              of_this_one.map { |item| row_for(item) },
              widths: { 1 => 70, 2 => 70, 3 => 52, 4 => 78 },
              align: { 2 => :right, 3 => :right })
      end
    end

    def row_for(item)
      [ item.name, item.code, item.quantity_label, item.minimum.to_s,
        item.status_label.capitalize, blank(item.location) ]
    end

    def inventories
      @inventories ||= @inventory ? [ @inventory ] : Inventory.by_name.to_a
    end

    def items
      @items ||= InventoryItem.where(inventory: inventories).by_name.to_a
    end
end

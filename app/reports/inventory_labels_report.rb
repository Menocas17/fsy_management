require "rqrcode"

# Hoja de etiquetas para recortar y pegar en las cajas: QR, nombre y código de cada artículo.
class InventoryLabelsReport < ApplicationReport
  filename_stem "etiquetas"

  COLUMNS = 3
  ROWS = 6
  QR_SIZE = 54

  def initialize(inventory: nil)
    @inventory = inventory
  end

  private
    def title
      @inventory ? "Etiquetas QR · #{@inventory.name}" : "Etiquetas QR del inventario"
    end

    def subtitle
      "#{items.size} #{items.size == 1 ? 'etiqueta' : 'etiquetas'} · recortá por la línea punteada"
    end

    def build(pdf)
      return table(pdf, [], []) if items.empty?

      cell_width = pdf.bounds.width / COLUMNS
      cell_height = 96

      items.each_slice(COLUMNS * ROWS).with_index do |page_items, page|
        pdf.start_new_page if page.positive?

        page_items.each_with_index do |item, index|
          column = index % COLUMNS
          row = index / COLUMNS
          top = pdf.bounds.top - row * cell_height

          pdf.bounding_box([ column * cell_width, top ], width: cell_width, height: cell_height) do
            pdf.dash(2, space: 2)
            pdf.stroke_color LINE
            pdf.stroke_bounds
            pdf.undash

            pdf.image qr_for(item), at: [ 8, pdf.bounds.top - 8 ], fit: [ QR_SIZE, QR_SIZE ]
            text_left = QR_SIZE + 16
            pdf.fill_color NAVY
            pdf.text_box item.name, at: [ text_left, pdf.bounds.top - 12 ],
                         width: cell_width - text_left - 8, height: 34, size: 9, style: :bold, overflow: :shrink_to_fit
            pdf.fill_color SLATE
            pdf.text_box item.code, at: [ text_left, pdf.bounds.top - 50 ],
                         width: cell_width - text_left - 8, size: 8.5, style: :bold
            pdf.text_box item.inventory.name, at: [ text_left, pdf.bounds.top - 64 ],
                         width: cell_width - text_left - 8, size: 7.5
            pdf.fill_color "000000"
          end
        end
      end
    end

    # rqrcode entrega el PNG en memoria; Prawn lo dibuja sin pasar por disco.
    def qr_for(item)
      StringIO.new(RQRCode::QRCode.new(item.qr_payload, level: :m).as_png(size: 240, border_modules: 0).to_s)
    end

    def items
      @items ||= InventoryItem.includes(:inventory)
                              .where(@inventory ? { inventory: @inventory } : {})
                              .order("inventories.name", :code)
                              .references(:inventories).to_a
    end
end

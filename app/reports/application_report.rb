require "prawn"
require "prawn/table"

# Base de los reportes imprimibles: membrete FSY, pie con paginado y una tabla con el mismo
# lenguaje visual de la app. Cada reporte concreto solo implementa #build.
class ApplicationReport
  # Las fuentes integradas de Prawn son WinAnsi, no UTF-8: alcanzan para el español y evitan
  # cargar un .ttf al repositorio. El aviso de Prawn sobre esto no aporta nada aquí.
  Prawn::Fonts::AFM.hide_m17n_warning = true

  EVENT = "FSY 2027 · Managua-Caribe".freeze
  NAVY = "1D2B4A".freeze
  SLATE = "5B6478".freeze
  LINE = "D8DCE3".freeze
  ZEBRA = "F4F6F9".freeze

  class_attribute :page_layout, default: :portrait

  def self.filename_stem(stem = nil)
    @filename_stem = stem if stem
    @filename_stem || name.underscore.delete_suffix("_report")
  end

  def filename
    "#{self.class.filename_stem}-#{Date.current.strftime('%Y-%m-%d')}.pdf"
  end

  def render
    document.tap do |pdf|
      build(pdf)
      page_furniture(pdf)
    end.render
  end

  private
    # Cada reporte dibuja su contenido aquí.
    def build(pdf)
      raise NotImplementedError
    end

    def title
      raise NotImplementedError
    end

    def subtitle
      nil
    end

    def document
      Prawn::Document.new(page_size: "A4", page_layout: self.class.page_layout,
                          margin: [ 96, 36, 54, 36 ], info: pdf_info)
    end

    def pdf_info
      { Title: title, Author: "FSY Management", Creator: "FSY Management",
        CreationDate: Time.current, Subject: EVENT }
    end

    # El membrete y el pie se repiten en todas las páginas, incluidas las que agrega la tabla sola.
    def page_furniture(pdf)
      pdf.repeat(:all) { letterhead(pdf) }
      pdf.number_pages "Página <page> de <total>",
                       at: [ 0, -22 ], width: pdf.bounds.width, align: :right, size: 8, color: SLATE
      pdf.repeat(:all) do
        pdf.draw_text EVENT, at: [ 0, pdf.bounds.bottom - 22 ], size: 8, color: SLATE
      end
    end

    def letterhead(pdf)
      pdf.canvas do
        top = pdf.bounds.top - 30
        pdf.image mark_path, at: [ 36, top ], fit: [ 34, 34 ]
        pdf.fill_color NAVY
        pdf.text_box title, at: [ 78, top - 2 ], width: pdf.bounds.width - 114, size: 15, style: :bold
        pdf.fill_color SLATE
        pdf.text_box [ subtitle, EVENT ].compact.join(" · "),
                     at: [ 78, top - 21 ], width: pdf.bounds.width - 114, size: 8.5
        pdf.text_box "Generado el #{SpanishDates.long(Date.current)} de #{Date.current.year}",
                     at: [ 36, top - 40 ], width: pdf.bounds.width - 72, size: 8, align: :right
        pdf.fill_color LINE
        pdf.fill_rectangle [ 36, top - 46 ], pdf.bounds.width - 72, 1
        pdf.fill_color "000000"
      end
    end

    def mark_path
      Rails.root.join("app/assets/images/fsy-mark.png").to_s
    end

    def section_title(pdf, text)
      pdf.fill_color NAVY
      pdf.text text, size: 11, style: :bold
      pdf.fill_color "000000"
      pdf.move_down 4
    end

    # Tabla con encabezado repetido en cada página y filas alternadas, como las listas de la app.
    def table(pdf, headers, rows, widths: nil, align: {})
      if rows.empty?
        pdf.fill_color SLATE
        pdf.text "Sin registros para este reporte.", size: 10, style: :italic
        pdf.fill_color "000000"
        return
      end

      pdf.table([ headers ] + rows, header: true, width: pdf.bounds.width,
                column_widths: widths, cell_style: { size: 8.5, padding: [ 5, 6 ], border_color: LINE, borders: [ :bottom ] }) do |t|
        t.row(0).font_style = :bold
        t.row(0).size = 8
        t.row(0).text_color = NAVY
        t.row(0).background_color = ZEBRA
        t.row(0).borders = [ :bottom ]
        align.each { |column, direction| t.column(column).align = direction }
        (1...t.row_length).step(2) { |index| t.row(index).background_color = "FFFFFF" }
      end
      pdf.move_down 10
    end

    def blank(value)
      value.presence || "—"
    end
end

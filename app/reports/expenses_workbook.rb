require "caxlsx"

# La rendición de gastos en Excel, para que tesorería la trabaje: una hoja por vista y los montos como
# números (no como texto), así se pueden sumar y filtrar.
class ExpensesWorkbook
  CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet".freeze

  def filename
    "rendicion-de-gastos-#{Date.current.strftime('%Y-%m-%d')}.xlsx"
  end

  def render
    package = Axlsx::Package.new
    book = package.workbook
    @styles = styles(book)

    summary_sheet(book)
    expenses_sheet(book)
    categories_sheet(book) if summary.rows.any?
    package.to_stream.read
  end

  private
    def summary_sheet(book)
      total = summary.total
      book.add_worksheet(name: "Resumen") do |sheet|
        sheet.add_row [ "#{Rails.configuration.x.event_name} · Rendición de gastos" ], style: @styles[:title]
        sheet.add_row [ "Generado el #{Date.current.strftime('%d/%m/%Y')} · montos en córdobas" ]
        sheet.add_row []
        [ [ "Presupuesto general", total.budget ], [ "Ejecutado", total.executed ], [ "Comprometido", total.committed ],
          [ "Disponible", total.available ], [ "Por aprobar", total.presented ] ].each do |label, cents|
          sheet.add_row [ label, to_amount(cents) ], style: [ @styles[:bold], @styles[:money] ]
        end
        rate = FinanceSettings.usd_rate
        sheet.add_row [ "Tipo de cambio del evento (C$ por US$)", rate&.to_f ], style: [ @styles[:bold], nil ] if rate
        sheet.column_widths 40, 18
      end
    end

    def expenses_sheet(book)
      headers = [ "Etapa", "Concepto", "Categoría", "Área", "Proveedor", "Moneda", "Estimado", "Real", "Tipo de cambio",
                  "Real en C$", "Fecha de compra", "Forma de pago", "Comprobante", "Justificación",
                  "Presentó", "Aprobó", "Consolidó", "Notas" ]
      book.add_worksheet(name: "Gastos") do |sheet|
        sheet.add_row headers, style: @styles[:header]
        Expense.includes(:expense_category, :logistics_area, receipt_attachment: :blob).order(:created_at).find_each do |e|
          sheet.add_row [ e.status_label, e.concept, e.category_name, e.logistics_area&.name, e.vendor, e.currency,
                          to_amount(e.estimated_cents), to_amount(e.actual_cents), e.exchange_rate.to_f, to_amount(e.actual_base_cents),
                          e.spent_on, Expense::PAYMENT_LABELS[e.payment_method],
                          (e.receipt.attached? ? "Factura" : (e.justification.present? ? "Justificado" : "—")), e.justification,
                          e.presented_by_name, e.approved_by_name, e.consolidated_by_name, e.notes ],
                        style: [ nil, nil, nil, nil, nil, nil, @styles[:money], @styles[:money], nil, @styles[:money], @styles[:date] ],
                        types: [ :string, :string, :string, :string, :string, :string, :float, :float, :float, :float, :date ]
        end
        sheet.auto_filter = "A1:R1"
        sheet.sheet_view.pane { |pane| pane.top_left_cell = "A2"; pane.state = :frozen; pane.y_split = 1 }
        sheet.column_widths 22, 34, 18, 16, 20, 8, 12, 12, 10, 14, 12, 14, 12, 40, 22, 22, 22, 30
      end
    end

    def categories_sheet(book)
      book.add_worksheet(name: "Por categoría") do |sheet|
        sheet.add_row [ "Categoría", "Presupuesto", "Ejecutado", "Comprometido", "Disponible", "Por aprobar" ], style: @styles[:header]
        summary.rows.each do |row|
          sheet.add_row [ row.name, to_amount(row.budget), to_amount(row.executed), to_amount(row.committed),
                          to_amount(row.available), to_amount(row.presented) ],
                        style: [ nil ] + [ @styles[:money] ] * 5
        end
        sheet.column_widths 26, 16, 16, 16, 16, 16
      end
    end

    def styles(book)
      book.styles.then do |s|
        { title: s.add_style(b: true, sz: 14),
          header: s.add_style(b: true, bg_color: "E9EDF3", border: { style: :thin, color: "D8DCE3" }),
          bold: s.add_style(b: true),
          money: s.add_style(num_fmt: 4),
          date: s.add_style(format_code: "dd/mm/yyyy") }
      end
    end

    def to_amount(cents)
      cents && cents / 100.0
    end

    def summary
      @summary ||= FinanceSummary.new
    end
end

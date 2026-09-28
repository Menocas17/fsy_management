# Rendición de gastos para tesorería (docs/finanzas.md, fase 2): el presupuesto contra lo gastado, por
# categoría y por área, el detalle de cada gasto consolidado con quién dio cada paso, lo que aún espera
# factura, los justificados sin factura y, al final, las facturas mismas.
class ExpensesReport < ApplicationReport
  filename_stem "rendicion-de-gastos"
  self.page_layout = :landscape

  RECEIPT_BOX = [ 700, 400 ].freeze

  private
    def title
      "Rendición de gastos"
    end

    def subtitle
      "#{consolidated.size} #{consolidated.size == 1 ? 'gasto consolidado' : 'gastos consolidados'} · montos en córdobas"
    end

    def build(pdf)
      summary_section(pdf)
      categories_section(pdf)
      areas_section(pdf)
      detail_section(pdf)
      pending_section(pdf)
      justified_section(pdf)
      receipts_annex(pdf)
    end

    def summary_section(pdf)
      total = summary.total
      section_title(pdf, "Resumen")
      table(pdf, [ "Presupuesto general", "Ejecutado", "Comprometido", "Disponible", "Por aprobar" ],
            [ [ money(total.budget), money(total.executed), money(total.committed), money(total.available), money(total.presented) ] ],
            align: { 0 => :right, 1 => :right, 2 => :right, 3 => :right, 4 => :right })
      rate = FinanceSettings.usd_rate
      note(pdf, "Tipo de cambio del evento: C$ #{rate} por dólar. Cada gasto en dólares usa el suyo, indicado en el detalle.") if rate
    end

    def categories_section(pdf)
      return if summary.rows.empty?

      section_title(pdf, "Por categoría")
      table(pdf, [ "Categoría", "Presupuesto", "Ejecutado", "Comprometido", "Disponible" ],
            summary.rows.map { |row| [ row.name, row.budget ? money(row.budget) : "—", money(row.executed), money(row.committed), row.budget ? money(row.available) : "—" ] },
            align: { 1 => :right, 2 => :right, 3 => :right, 4 => :right })
    end

    def areas_section(pdf)
      by_area = consolidated.group_by { |expense| expense.logistics_area&.name || "Sin área" }
      return if by_area.empty?

      section_title(pdf, "Ejecutado por área")
      table(pdf, [ "Área", "Gastos", "Ejecutado" ],
            by_area.sort_by { |name, _| name }.map { |name, expenses| [ name, expenses.size.to_s, money(expenses.sum(&:actual_base_cents)) ] },
            align: { 1 => :right, 2 => :right })
    end

    def detail_section(pdf)
      pdf.start_new_page
      section_title(pdf, "Detalle de gastos consolidados")
      table(pdf, [ "N.º", "Fecha", "Concepto · proveedor", "Categoría · área", "Monto", "En C$", "Pago", "Comprobante", "Presentó / aprobó / consolidó" ],
            consolidated.each_with_index.map { |expense, index| detail_row(expense, index + 1) },
            widths: { 0 => 24, 1 => 64, 3 => 100, 4 => 76, 5 => 72, 6 => 72, 7 => 74, 8 => 164 },
            align: { 0 => :right, 4 => :right, 5 => :right })
    end

    # Proveedor bajo el concepto y área bajo la categoría: así ninguna columna queda tan angosta que parta
    # las fechas o los nombres.
    def detail_row(expense, number)
      original = expense.usd? ? "#{Money.format(expense.actual_cents, 'USD')}\n× #{expense.exchange_rate}" : Money.format(expense.actual_cents)
      [ number.to_s, (expense.spent_on&.strftime("%d/%m/%Y") || "—"),
        [ expense.concept, expense.vendor.presence ].compact.join("\n"),
        [ expense.category_name, expense.logistics_area&.name ].compact.join("\n"),
        original, money(expense.actual_base_cents), blank(Expense::PAYMENT_LABELS[expense.payment_method]),
        expense.receipt.attached? ? "Factura\n(anexo #{number})" : "Justificado",
        [ expense.presented_by_name, expense.approved_by_name, expense.consolidated_by_name ].join("\n") ]
    end

    def pending_section(pdf)
      pending = Expense.committed.includes(:expense_category).order(:approved_at).to_a
      return if pending.empty?

      section_title(pdf, "Aprobados que aún esperan su factura")
      table(pdf, [ "Concepto", "Categoría", "Estimado", "C$", "Aprobado por", "Etapa" ],
            pending.map { |e| [ e.concept, e.category_name, Money.format(e.estimated_cents, e.currency), money(e.estimated_base_cents), e.approved_by_name, e.status_label ] },
            align: { 2 => :right, 3 => :right })
    end

    def justified_section(pdf)
      justified = consolidated.reject { |expense| expense.receipt.attached? }
      return if justified.empty?

      section_title(pdf, "Consolidados sin factura (justificados)")
      table(pdf, [ "Concepto", "C$", "Justificación", "La escribió", "La aprobó" ],
            justified.map { |e| [ e.concept, money(e.actual_base_cents), e.justification.to_s, e.justified_by_name, e.consolidated_by_name ] },
            widths: { 1 => 70 }, align: { 1 => :right })
    end

    # Una factura por página, con su número del detalle. Las fotos se reducen y pasan a JPEG (así entran
    # también las HEIC del iPhone); un PDF no se puede incrustar y queda indicado para adjuntarlo aparte.
    def receipts_annex(pdf)
      with_receipt = consolidated.each_with_index.select { |expense, _| expense.receipt.attached? }
      return if with_receipt.empty?

      with_receipt.each do |expense, index|
        pdf.start_new_page
        section_title(pdf, "Anexo #{index + 1} · #{expense.concept} · #{money(expense.actual_base_cents)}")
        if expense.receipt.image?
          image = receipt_image(expense)
          image ? pdf.image(image, fit: RECEIPT_BOX, position: :center) : note(pdf, "No se pudo leer la foto (#{expense.receipt.filename}).")
        else
          note(pdf, "Factura en PDF: #{expense.receipt.filename}. Se adjunta aparte.")
        end
      end
    end

    def receipt_image(expense)
      StringIO.new(expense.receipt.variant(resize_to_limit: [ 1600, 1600 ], format: :jpeg).processed.download)
    rescue StandardError
      nil
    end

    def note(pdf, text)
      pdf.fill_color SLATE
      pdf.text text, size: 8.5
      pdf.fill_color "000000"
      pdf.move_down 8
    end

    def money(cents)
      Money.format(cents)
    end

    def summary
      @summary ||= FinanceSummary.new
    end

    def consolidated
      @consolidated ||= Expense.consolidated.includes(:expense_category, :logistics_area, receipt_attachment: :blob)
                               .order(:spent_on, :consolidated_at).to_a
    end
end

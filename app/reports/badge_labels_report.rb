require "rqrcode"

# Gafetes para los lanyards: por participante, una etiqueta de frente con su nombre y compañía y
# otra con el QR de su ficha para pegar detrás. Van lado a lado para no confundir los pares.
class BadgeLabelsReport < ApplicationReport
  filename_stem "gafetes"

  SCOPES = {
    "todos"   => "Gafetes",
    "jovenes" => "Gafetes · Jóvenes",
    "staff"   => "Gafetes · Staff"
  }.freeze

  # Tamaño tarjeta de crédito (85,6 × 54 mm): cabe en las fundas de lanyard estándar.
  LABEL_WIDTH = 242
  LABEL_HEIGHT = 153
  ROWS = 4
  QR_SIZE = 104

  # qr_url recibe al participante y devuelve la URL de su ficha; el reporte no conoce las rutas.
  def initialize(qr_url:, scope: "todos", company: nil)
    @qr_url = qr_url
    @scope = SCOPES.key?(scope.to_s) ? scope.to_s : "todos"
    @company = company
  end

  def filename
    stem = [ self.class.filename_stem, (@scope unless @scope == "todos"), (@company && "compania-#{@company.number || @company.id}") ]
    "#{stem.compact.join('-')}-#{Date.current.strftime('%Y-%m-%d')}.pdf"
  end

  private
    def title
      [ SCOPES.fetch(@scope), @company&.name ].compact.join(" · ")
    end

    def subtitle
      "#{participants.size} #{participants.size == 1 ? 'gafete' : 'gafetes'} · recortá por la línea punteada"
    end

    def build(pdf)
      return table(pdf, [], []) if participants.empty?

      gap = pdf.bounds.width - LABEL_WIDTH * 2
      row_gap = (pdf.bounds.height - LABEL_HEIGHT * ROWS) / (ROWS - 1)

      participants.each_slice(ROWS).with_index do |page_people, page|
        pdf.start_new_page if page.positive?

        page_people.each_with_index do |participant, row|
          top = pdf.bounds.top - row * (LABEL_HEIGHT + row_gap)
          label(pdf, [ 0, top ]) { front(pdf, participant) }
          label(pdf, [ LABEL_WIDTH + gap, top ]) { back(pdf, participant) }
        end
      end
    end

    def label(pdf, at, &block)
      pdf.bounding_box(at, width: LABEL_WIDTH, height: LABEL_HEIGHT) do
        pdf.dash(2, space: 2)
        pdf.stroke_color LINE
        pdf.stroke_bounds
        pdf.undash
        block.call
        pdf.fill_color "000000"
      end
    end

    # Frente: el nombre grande y la compañía debajo, centrados en la etiqueta.
    def front(pdf, participant)
      padding = 22
      pdf.fill_color NAVY
      pdf.text_box participant.first_name.to_s, at: [ 12, pdf.bounds.top - padding - 14 ], width: LABEL_WIDTH - 24,
                   height: 30, size: 24, style: :bold, align: :center, overflow: :shrink_to_fit
      pdf.text_box participant.last_name.to_s, at: [ 12, pdf.bounds.top - padding - 46 ], width: LABEL_WIDTH - 24,
                   height: 18, size: 13, align: :center, overflow: :shrink_to_fit

      pdf.fill_color LINE
      pdf.fill_rectangle [ 40, pdf.bounds.top - padding - 72 ], LABEL_WIDTH - 80, 1
      pdf.fill_color SLATE
      pdf.text_box company_label(participant), at: [ 12, pdf.bounds.top - padding - 80 ], width: LABEL_WIDTH - 24,
                   height: 16, size: 11, style: :bold, align: :center, overflow: :shrink_to_fit
      pdf.text_box participant.role_label, at: [ 12, pdf.bounds.top - padding - 96 ], width: LABEL_WIDTH - 24,
                   height: 12, size: 8.5, align: :center, overflow: :shrink_to_fit
    end

    # Reverso: el QR de la ficha, con el nombre en chico para saber de quién es al pegarlo.
    def back(pdf, participant)
      pdf.image qr_for(participant), at: [ 14, pdf.bounds.top - (LABEL_HEIGHT - QR_SIZE) / 2 ], fit: [ QR_SIZE, QR_SIZE ]
      text_left = QR_SIZE + 26
      # Un nombre largo empuja la compañía hacia abajo, pero nunca sale de la etiqueta.
      width = LABEL_WIDTH - text_left - 10
      top = pdf.bounds.top - 30
      name_height = [ pdf.height_of(participant.full_name, width: width, size: 10, style: :bold), 50 ].min
      pdf.fill_color NAVY
      pdf.text_box participant.full_name, at: [ text_left, top ], width: width, height: name_height,
                   size: 10, style: :bold, overflow: :shrink_to_fit
      top -= name_height + 5
      pdf.fill_color SLATE
      pdf.text_box company_label(participant), at: [ text_left, top ], width: width, height: 20,
                   size: 8, overflow: :shrink_to_fit
      pdf.text_box "Escaneá para abrir la ficha", at: [ text_left, top - 26 ], width: width, height: 10,
                   size: 7, style: :italic, overflow: :shrink_to_fit
    end

    # Los jóvenes tienen compañía propia; consejeros y auxiliares la tienen por su membresía.
    def company_label(participant)
      company = participant.company || participant.companies.first
      return company_name(company) if company
      return participant.auxiliar_companies.first.name if participant.auxiliar_companies.first

      participant.joven? ? "Sin compañía" : "Staff FSY"
    end

    # Solo el número: el nombre que elige la compañía se decide durante la semana.
    def company_name(company)
      company.number ? "Compañía #{company.number}" : company.name
    end

    def qr_for(participant)
      StringIO.new(RQRCode::QRCode.new(@qr_url.call(participant), level: :m).as_png(size: 360, border_modules: 0).to_s)
    end

    def participants
      @participants ||= begin
        relation = Participant.includes(:company, :companies, :auxiliar_companies)
        relation = case @scope
        when "jovenes" then relation.jovenes
        when "staff"   then relation.staff
        else relation
        end
        relation = relation.where(company: @company).or(relation.where(id: staff_ids)) if @company
        relation.to_a.sort_by { |participant| sort_key(participant) }
      end
    end

    # El staff de una compañía no tiene company_id: llega por su membresía.
    def staff_ids
      Membership.where(associable: @company).select(:participant_id)
    end

    # Primero por compañía para repartirlos por grupo, luego por nombre.
    def sort_key(participant)
      company = participant.company || participant.companies.first
      [ company&.number || Float::INFINITY, participant.first_name.to_s, participant.last_name.to_s ]
    end
end

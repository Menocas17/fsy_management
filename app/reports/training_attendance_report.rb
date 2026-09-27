# La asistencia del staff a las capacitaciones: una columna por fecha, para pasar lista en papel.
class TrainingAttendanceReport < ApplicationReport
  self.page_layout = :landscape
  filename_stem "capacitaciones"

  def initialize(training: nil)
    @training = training
  end

  private
    def title
      @training ? "Asistencia · #{@training.name}" : "Asistencia a las capacitaciones"
    end

    def subtitle
      return "#{@training.attended_count} de #{@training.expected_count} · #{SpanishDates.long(@training.held_on)}" if @training

      "#{trainings.size} #{trainings.size == 1 ? 'capacitación' : 'capacitaciones'} · #{staff.size} del staff"
    end

    def build(pdf)
      trainings.each do |training|
        section_title(pdf, "#{training.name} · #{SpanishDates.long(training.held_on)} · #{training.attended_count} de #{training.expected_count}")
      end
      pdf.move_down 6

      table(pdf, headers, rows, widths: { 0 => 190, 1 => 150 }, align: alignment)
    end

    def headers
      [ "Persona", "Rol", *trainings.map { |training| "#{training.held_on.day} #{SpanishDates.month(training.held_on).first(3)}" }, "Asistencia" ]
    end

    def rows
      staff.map do |person|
        held = trainings.reject { |training| training.held_on > Date.current }
        attended = held.count { |training| attended?(training, person) }

        [ person.full_name, role_line(person),
          *trainings.map { |training| mark(training, person) },
          held.any? ? "#{attended}/#{held.size}" : "—" ]
      end
    end

    # Ni «sí» ni «no» a secas: lo que todavía no ocurre se distingue de lo que se faltó.
    def mark(training, person)
      return "Sí" if attended?(training, person)
      return "—" if training.held_on > Date.current

      "No"
    end

    def attended?(training, person)
      attendance_index[training.id]&.include?(person.id)
    end

    def attendance_index
      @attendance_index ||= TrainingAttendance.where(training: trainings).pluck(:training_id, :participant_id)
                                              .group_by(&:first).transform_values { |pairs| pairs.map(&:last).to_set }
    end

    def role_line(person)
      [ person.role_label, person.company&.name || person.logistics_area&.name ].compact_blank.join(" · ")
    end

    def alignment
      (2..(trainings.size + 2)).index_with { :center }
    end

    def trainings
      @trainings ||= @training ? [ @training ] : Training.chronological.to_a
    end

    def staff
      @staff ||= Participant.staff.includes(:company, :logistics_area).order(:first_name, :last_name).to_a
    end
end

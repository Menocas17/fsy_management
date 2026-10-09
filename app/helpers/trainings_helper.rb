module TrainingsHelper
  # La confirmación de borrar una capacitación, igual desde su formulario que desde su tarjeta: dice cuántas
  # asistencias se pierden con ella.
  def training_delete_confirm(training)
    attended = training.attended_count
    detail = if attended.zero? then "No tiene asistencias registradas. No se puede deshacer."
    elsif attended == 1 then "Se pierde también la asistencia registrada de 1 persona. No se puede deshacer."
    else "Se pierden también las asistencias registradas de #{attended} personas. No se puede deshacer."
    end

    { turbo_confirm: "¿Borrar «#{training.name}»?", turbo_confirm_detail: detail, turbo_confirm_button: "Sí, borrar" }
  end
end

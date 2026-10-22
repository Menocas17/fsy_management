module ManualsHelper
  # Dónde guarda el dispositivo la página en la que iba la persona (pdf_reader_controller.js). Lleva el PDF en la
  # llave: un manual reemplazado empieza de nuevo desde la primera página.
  def manual_progress_key(manual)
    "fsy-manual-#{manual.kind}-#{manual.file.blob.checksum}"
  end
end

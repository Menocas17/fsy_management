# El código QR de una ficha para el diálogo «Mi QR» de la barra inferior, que está en todas las páginas: el
# diálogo trae un turbo-frame perezoso y el código se pide recién al abrirlo (participants/_qr_dialog, lazy).
class ParticipantQrsController < ApplicationController
  allow_jovenes
  def show
    participant = Participant.find(params[:participant_id])
    # El joven pide solo el suyo («Mi QR»); el de otro le diría de quién es la ficha.
    return head(:forbidden) if joven_signed_in? && participant != Current.user.participant

    render partial: "participants/qr_frame", locals: { participant: participant }
  end
end

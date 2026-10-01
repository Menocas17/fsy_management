# La cuenta de una ficha: crearla (con la contraseña predeterminada, que se pide cambiar al entrar) o
# devolverla a esa contraseña cuando la persona la olvidó, mientras no haya correo para recuperarla.
# Quién puede, en Authorization#can_create_account_for? y #can_reset_account_of?.
class ParticipantAccountsController < ApplicationController
  before_action :set_participant

  def create
    unless can_create_account_for?(@participant)
      return redirect_to participant_path(@participant), alert: "No puedes crear una cuenta para esta ficha."
    end

    user = User.create_for_participant(@participant, email: params[:email_address],
                                                     email_confirmation: params[:email_address_confirmation])
    if user.persisted?
      record_audit!(category: :cuentas, action: "created", target: @participant,
                    summary: "Creó la cuenta de #{@participant.full_name} (#{user.email_address})")
      redirect_to participant_path(@participant),
                  notice: "Se creó la cuenta de #{@participant.full_name}: entra con #{user.email_address} y la contraseña " \
                          "#{User::DEFAULT_PASSWORD}. Al entrar se le pedirá cambiarla."
    else
      redirect_to participant_path(@participant), alert: "No se creó la cuenta: #{user.errors.full_messages.to_sentence}."
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to participant_path(@participant), alert: "No se creó la cuenta: esta ficha o ese correo ya tienen una."
  end

  def update
    unless can_reset_account_of?(@participant)
      return redirect_to participant_path(@participant), alert: "No puedes restablecer la contraseña de esta cuenta."
    end

    user = @participant.user
    user.reset_to_default_password!
    record_audit!(category: :cuentas, action: "reset", target: @participant,
                  summary: "Restableció la contraseña de #{@participant.full_name} (#{user.email_address})")
    redirect_to participant_path(@participant),
                notice: "La contraseña de #{@participant.full_name} volvió a ser #{User::DEFAULT_PASSWORD}. " \
                        "Se cerraron sus sesiones y al entrar se le pedirá cambiarla."
  end

  private
    def set_participant
      @participant = Participant.includes(:user).find(params[:participant_id])
    end
end

# La cuenta de una ficha: crearla o restablecerla. En los dos casos la persona recibe por correo un enlace
# para elegir su contraseña (PasswordsMailer.invitation); nadie más la conoce nunca. Quién puede, en
# Authorization#can_create_account_for? y #can_reset_account_of?.
class ParticipantAccountsController < ApplicationController
  before_action :set_participant

  def create
    unless can_create_account_for?(@participant)
      return redirect_to participant_path(@participant), alert: "No puedes crear una cuenta para esta ficha."
    end

    user = User.create_for_participant(@participant, email: params[:email_address],
                                                     email_confirmation: params[:email_address_confirmation])
    if user.persisted?
      PasswordsMailer.invitation(user, reason: :new).deliver_later
      record_audit!(category: :cuentas, action: "created", target: @participant,
                    summary: "Creó la cuenta de #{@participant.full_name} (#{user.email_address})")
      redirect_to participant_path(@participant),
                  notice: "Se creó la cuenta de #{@participant.full_name}. Le llegó a #{user.email_address} un enlace " \
                          "para elegir su contraseña (vale #{User::INVITATION_VALID_FOR.in_days.to_i} días).#{link_for_testing(user)}"
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
    user.revoke_password!
    PasswordsMailer.invitation(user, reason: :reset).deliver_later
    record_audit!(category: :cuentas, action: "reset", target: @participant,
                  summary: "Restableció la contraseña de #{@participant.full_name} (#{user.email_address})")
    redirect_to participant_path(@participant),
                notice: "Se cerraron las sesiones de #{@participant.full_name} y le llegó a #{user.email_address} " \
                        "un enlace para elegir una contraseña nueva.#{link_for_testing(user)}"
  end

  private
    def set_participant
      @participant = Participant.includes(:user).find(params[:participant_id])
    end

    # En desarrollo sin correo real (los correos solo van al log), el enlace se muestra aquí para poder probar.
    def link_for_testing(user)
      return "" unless Rails.env.development? && ActionMailer::Base.delivery_method != :smtp

      " (Correo no enviado en desarrollo; enlace: #{edit_password_url(user.invitation_token)})"
    end
end

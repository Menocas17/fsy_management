# Ver los correos en http://localhost:3000/rails/mailers/passwords_mailer
class PasswordsMailerPreview < ActionMailer::Preview
  def reset
    PasswordsMailer.reset(user)
  end

  def invitation
    PasswordsMailer.invitation(user, reason: :new)
  end

  def invitation_after_reset
    PasswordsMailer.invitation(user, reason: :reset)
  end

  private
    def user
      User.where.not(participant_id: nil).take || User.take
    end
end

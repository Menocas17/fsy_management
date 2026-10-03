require "test_helper"

class ParticipantAccountsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @juan = participants(:juan)
    @admin = users(:one)
  end

  test "each account manager creates the account of a ficha that has none" do
    managers = { superadmin: @admin }
    { director: "H", coordinador: "M", director_logistica: "H" }.each do |rol, gender|
      managers[rol] = user_for(rol, gender: gender)
    end

    managers.each do |rol, manager|
      joven = person(:joven, first_name: "Joven #{rol}")
      sign_in_as(manager)

      assert_difference -> { User.count } do
        assert_enqueued_emails 1 do
          post participant_account_path(joven), params: { email_address: " Nuevo.#{rol}@FSY.com ", email_address_confirmation: "nuevo.#{rol}@fsy.com" }
        end
      end

      account = joven.reload.user
      assert_redirected_to participant_path(joven)
      assert_equal "nuevo.#{rol}@fsy.com", account.email_address
      assert_no_match(/contraseña [A-Za-z0-9]+!/, flash[:notice], "#{rol}: no password is ever shown")
      assert_not account.superadmin?
      assert_equal "cuentas", AuditLog.order(:created_at).last.category
    end
  end

  test "with an email on the ficha, the dialog asks whether to use it or another" do
    @juan.update!(email_address: "juan@correo.com")
    sign_in_as(@admin)

    get participant_path(@juan)

    assert_select "[data-contact-email] button[data-dialog-name='account']", text: /Crear cuenta/
    assert_select "[data-profile-actions] button[data-dialog-name='account']", 0
    assert_select "dialog[data-dialog-name='account'] form[action='#{participant_account_path(@juan)}']" do
      assert_select "[data-email-choice='ficha']", text: /juan@correo.com/
      assert_select "input[name='email_choice'][value='ficha'][checked]"
      assert_select "input[name='email_address'][disabled]"
    end
  end

  test "using the ficha's email needs no typing" do
    @juan.update!(email_address: "Juan@Correo.com")
    sign_in_as(@admin)

    post participant_account_path(@juan), params: { email_choice: "ficha" }

    assert_equal "juan@correo.com", @juan.reload.user.email_address
  end

  test "another email becomes the ficha's email too" do
    @juan.update!(email_address: "viejo@correo.com")
    sign_in_as(@admin)

    post participant_account_path(@juan), params: { email_choice: "otro", email_address: "nuevo@correo.com", email_address_confirmation: "nuevo@correo.com" }

    assert_equal "nuevo@correo.com", @juan.reload.user.email_address
    assert_equal "nuevo@correo.com", @juan.email_address
  end

  test "a ficha without email asks for one and keeps it" do
    sign_in_as(@admin)

    get participant_path(@juan)
    assert_select "dialog[data-dialog-name='account']" do
      assert_select "input[name='email_choice']", 0
      assert_select "input[name='email_address']:not([disabled])"
    end

    post participant_account_path(@juan), params: { email_address: "juan@fsy.com", email_address_confirmation: "juan@fsy.com" }
    assert_equal "juan@fsy.com", @juan.reload.email_address
  end

  test "a mistyped other email changes neither the account nor the ficha" do
    @juan.update!(email_address: "viejo@correo.com")
    sign_in_as(@admin)

    assert_no_difference -> { User.count } do
      post participant_account_path(@juan), params: { email_choice: "otro", email_address: "nuevo@correo.com", email_address_confirmation: "nuveo@correo.com" }
    end
    assert_equal "viejo@correo.com", @juan.reload.email_address
  end

  test "the contact section says when an account has never been used, until its first sign-in" do
    account = User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: @juan)
    sign_in_as(@admin)

    get participant_path(@juan)
    assert_select "[data-contact-email]", text: /juan@fsy.com/
    assert_select "[data-contact-email] [data-info-badge]", text: "Todavía no entra"

    account.signed_in!
    account.sessions.destroy_all # cerró sesión: sigue contando como que ya entró
    get participant_path(@juan)
    assert_select "[data-contact-email] [data-info-badge]", 0
  end

  test "a mistyped confirmation creates nothing and says why" do
    sign_in_as(@admin)

    assert_no_difference -> { User.count } do
      post participant_account_path(@juan), params: { email_address: "juan@fsy.com", email_address_confirmation: "jaun@fsy.com" }
    end

    assert_redirected_to participant_path(@juan)
    assert_match(/no coincide/, flash[:alert])
  end

  test "an email already in use creates nothing" do
    sign_in_as(@admin)

    assert_no_difference -> { User.count } do
      post participant_account_path(@juan), params: { email_address: @admin.email_address, email_address_confirmation: @admin.email_address }
    end
    assert_match(/ya está en uso/, flash[:alert])
  end

  test "a ficha that already has an account gets the reset button instead, never a second account" do
    User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: @juan)
    sign_in_as(@admin)

    get participant_path(@juan)
    assert_select "button[data-dialog-name='account']", 0
    assert_select "[data-contact-email] form[action='#{participant_account_path(@juan)}'] button", text: /Restablecer contraseña/

    assert_no_difference -> { User.count } do
      post participant_account_path(@juan), params: { email_address: "otro@fsy.com", email_address_confirmation: "otro@fsy.com" }
    end
  end

  test "nobody else creates or resets accounts, and they don't see the buttons" do
    %i[consejero registrador logistica auxiliar].each do |rol|
      sign_in_as(user_for(rol))

      get participant_path(@juan)
      assert_select "button[data-dialog-name='account']", 0
      assert_select "[data-contact-email] [data-info-badge]", 0

      assert_no_difference -> { User.count } do
        post participant_account_path(@juan), params: { email_address: "juan@fsy.com", email_address_confirmation: "juan@fsy.com" }
      end
      assert_redirected_to participant_path(@juan)
    end
  end

  test "the logistics director handles anyone's account except the director's and the coordinators'" do
    sign_in_as(user_for(:director_logistica))
    counselor = person(:consejero, gender: "H")
    coordinator = person(:coordinador)

    post participant_account_path(counselor), params: { email_address: "consejero@fsy.com", email_address_confirmation: "consejero@fsy.com" }
    assert counselor.reload.user, "a new counselor registered by logística"

    get participant_path(coordinator)
    assert_select "button[data-dialog-name='account']", 0
    post participant_account_path(coordinator), params: { email_address: "coor@fsy.com", email_address_confirmation: "coor@fsy.com" }
    assert_nil coordinator.reload.user

    coordinator_user = User.create!(email_address: "coor@fsy.com", password: "Coordina1!", participant: coordinator)
    patch participant_account_path(coordinator)
    assert coordinator_user.reload.authenticate("Coordina1!"), "a reset would let them sign in as a coordinator"
  end

  test "resetting voids the old password, closes the sessions and emails a link to choose another" do
    account = User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: @juan)
    account.sessions.create!
    sign_in_as(user_for(:coordinador))

    assert_enqueued_emails 1 do
      patch participant_account_path(@juan)
    end

    assert_redirected_to participant_path(@juan)
    account.reload
    assert_not account.authenticate("Joven1234!")
    assert_equal 0, account.sessions.count
    assert_equal "reset", AuditLog.order(:created_at).last.action
  end

  test "the emailed link lets the new account choose its password, only once" do
    sign_in_as(@admin)
    post participant_account_path(@juan), params: { email_address: "juan@fsy.com", email_address_confirmation: "juan@fsy.com" }
    account = @juan.reload.user
    sign_out

    mail = PasswordsMailer.invitation(account, reason: :new)
    link = mail.text_part.body.to_s[%r{http://\S+}]
    assert_equal [ "juan@fsy.com" ], mail.to

    get link
    assert_response :success
    assert_select "h1", text: /Bienvenido/

    put URI(link).request_uri.sub("/edit", ""), params: { password: "MiClave2027!", password_confirmation: "MiClave2027!" }
    assert_redirected_to new_session_path
    assert account.reload.authenticate("MiClave2027!")

    get link
    assert_redirected_to new_password_path, "the link dies once the password is chosen"
    assert_match(/no es válido o ha caducado/, flash[:alert])
  end

  test "the invitation link expires" do
    account = User.create_for_participant(@juan, email: "juan@fsy.com", email_confirmation: "juan@fsy.com")
    token = account.invitation_token

    travel User::INVITATION_VALID_FOR + 1.minute do
      get edit_password_path(token)
      assert_redirected_to new_password_path
    end
  end

  test "an account just created cannot be entered with any password anyone knows" do
    account = User.create_for_participant(@juan, email: "juan@fsy.com", email_confirmation: "juan@fsy.com")

    # La que antes era la predeterminada para todas las cuentas nuevas.
    post session_path, params: { email_address: "juan@fsy.com", password: "FsyManagua2026!" }

    assert_redirected_to new_session_path
    assert_equal 0, account.sessions.count
  end

  test "nobody resets their own account from their ficha" do
    coordinator = user_for(:coordinador)
    sign_in_as(coordinator)

    get participant_path(coordinator.participant)
    assert_select "form[action='#{participant_account_path(coordinator.participant)}']", 0

    assert_no_enqueued_emails do
      patch participant_account_path(coordinator.participant)
    end
    assert coordinator.reload.authenticate("Cuenta123!")
  end

  private
    def person(rol, gender: "M", first_name: rol.to_s.titleize)
      Participant.create!(first_name: first_name, last_name: "Prueba", age: 30, stake: "villa_flor", shirt_number: "m",
                          gender: gender, rol: rol)
    end

    def user_for(rol, gender: "M")
      participant = person(rol, gender: gender)
      User.create!(email_address: "#{rol}.#{participant.id.first(6)}@fsy.com", password: "Cuenta123!", participant: participant)
    end
end

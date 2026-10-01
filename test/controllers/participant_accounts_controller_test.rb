require "test_helper"

class ParticipantAccountsControllerTest < ActionDispatch::IntegrationTest
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
        post participant_account_path(joven), params: { email_address: " Nuevo.#{rol}@FSY.com ", email_address_confirmation: "nuevo.#{rol}@fsy.com" }
      end

      account = joven.reload.user
      assert_redirected_to participant_path(joven)
      assert_equal "nuevo.#{rol}@fsy.com", account.email_address
      assert account.must_change_password?, "#{rol}: the account starts on the default password"
      assert account.authenticate(User::DEFAULT_PASSWORD)
      assert_not account.superadmin?
      assert_equal "cuentas", AuditLog.order(:created_at).last.category
    end
  end

  test "the profile offers the button and a dialog with the ficha's email filled in" do
    @juan.update!(email_address: "juan@correo.com")
    sign_in_as(@admin)

    get participant_path(@juan)

    assert_select "[data-profile-actions] button[data-dialog-name='account']", text: /Crear cuenta/
    assert_select "dialog[data-dialog-name='account'] form[action='#{participant_account_path(@juan)}']" do
      assert_select "input[name='email_address'][value='juan@correo.com']"
      assert_select "input[name='email_address_confirmation']:not([value])"
    end
    assert_select "[data-account-status]", text: /Sin cuenta/
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
    assert_select "form[action='#{participant_account_path(@juan)}'] button", text: /Restablecer contraseña/
    assert_select "[data-account-status]", text: /juan@fsy.com/

    assert_no_difference -> { User.count } do
      post participant_account_path(@juan), params: { email_address: "otro@fsy.com", email_address_confirmation: "otro@fsy.com" }
    end
  end

  test "nobody else creates or resets accounts, and they don't see the buttons" do
    %i[consejero registrador logistica auxiliar].each do |rol|
      sign_in_as(user_for(rol))

      get participant_path(@juan)
      assert_select "button[data-dialog-name='account']", 0
      assert_select "[data-account-status]", 0

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

  test "resetting puts the default password back, closes the sessions and asks to change it again" do
    account = User.create!(email_address: "juan@fsy.com", password: "Joven1234!", participant: @juan)
    account.sessions.create!
    sign_in_as(user_for(:coordinador))

    patch participant_account_path(@juan)

    assert_redirected_to participant_path(@juan)
    account.reload
    assert account.authenticate(User::DEFAULT_PASSWORD)
    assert account.must_change_password?
    assert_equal 0, account.sessions.count
    assert_equal "reset", AuditLog.order(:created_at).last.action
  end

  test "nobody resets their own account from their ficha" do
    coordinator = user_for(:coordinador)
    sign_in_as(coordinator)

    get participant_path(coordinator.participant)
    assert_select "form[action='#{participant_account_path(coordinator.participant)}']", 0

    patch participant_account_path(coordinator.participant)
    assert_not coordinator.reload.must_change_password?
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

class Current < ActiveSupport::CurrentAttributes
  attribute :session, :viewing_as

  # El superadmin puede ver la app como otra persona (ViewAsController): entonces user es esa persona —su
  # menú y sus permisos, tal cual— y real_user sigue siendo la cuenta que de verdad inició sesión.
  def user
    viewing_as || real_user
  end

  def real_user
    session&.user
  end

  def viewing_as?
    viewing_as.present?
  end
end

# User accounts: login/logout review and account-creation plan

Status: **implemented** (sections 2–5) on `claude/wonderful-volta-ritwqr`, then **revised on `rmenocal/cuentas-staff`**: the shared default password (`FsyManagua2026!`) was dropped. The repo is public, so anyone who knew a staff member's email could sign in before them and pick the password themselves — including on a coordinator's account. Now that Gmail SMTP works, a new or reset account gets a random password nobody sees and an emailed link (`PasswordsMailer.invitation`, valid `User::INVITATION_VALID_FOR`, single use) to choose its own; `must_change_password` and the forced-change screen went away with it. Sections 2–5 below describe the original default-password design and are kept for history. Decisions still in force: the logistics director creates accounts for anyone (they run registration), except a director's or coordinator's account, which only full access touches.

## 1. Review of the current login / logout

### What works
- Rails 8 authentication generator, customized: `has_secure_password` on `User`, a DB-backed `Session` per device, signed `httponly`/`same_site: :lax` cookie, `force_ssl` in production.
- `SessionsController#create` uses `User.authenticate_by` (constant-time, no user enumeration), is rate-limited (10 / 3 min) and records every attempt in `LoginAttempt` (shown in *Accesos*).
- Sessions expire after 30 days idle (`Session::IDLE_LIMIT`) and record activity every 5 minutes (`seen!`).
- Logout (`DELETE /session`) destroys the session row and the cookie; it is a `button_to` (POST + `_method=delete`), so it is CSRF-protected. The superadmin can also close any session remotely from *Accesos*.
- Password rules: ≥ 8 characters, a digit, an uppercase letter and a punctuation mark. `FsyManagua2026!` passes them.

### Problems found (ordered by severity)

| # | Severity | Problem | Where |
|---|----------|---------|-------|
| 1 | **High** | **Deleting a participant turns their account into a superadmin.** `Participant has_one :user, dependent: :nullify` sets `users.participant_id = NULL`, and `User#superadmin?` / `#full_access?` are defined as `participant_id.nil?`. A `director_logistica` deleting a `logistica` member who has an account grants that member full access. More accounts (this feature) means more exposure. | `app/models/participant.rb:2`, `app/models/user.rb` (`superadmin?`, `full_access?`, `alert_manager?`, `agenda_manager?`) |
| 2 | **High** | **Passwords are written to the logs in plain text.** The Rails default `:passw` (and `:email`) entries were removed from `filter_parameters`, so every login, reset and (future) password change logs the password. | `config/initializers/filter_parameter_logging.rb` |
| 3 | Medium | No model validation of email uniqueness/format on `User` — only the DB unique index, so a duplicate raises `ActiveRecord::RecordNotUnique` (500) instead of a form error. | `app/models/user.rb` |
| 4 | Medium | `users.participant_id` index is not unique, so a participant can end up with two accounts while the model says `has_one`. | `db/schema.rb` |
| 5 | Medium | Email-based reset is wired to the UI (*Configuración*, *Mi perfil → editar*, *¿Olvidaste tu contraseña?*) but production SMTP is commented out: jobs fail silently and the user is told "se ha enviado el enlace". | `config/environments/production.rb`, `PasswordsController`, `SettingsController`, `ParticipantsController#send_password_reset` |
| 6 | Low | `PasswordsController#update` redirects on failure, so `@user.errors` (rendered in `passwords/edit`) never reach the page; every failure reads "Las contraseñas no coinciden" even when it is the complexity rule. `update` is not rate-limited. | `app/controllers/passwords_controller.rb` |
| 7 | Low | A logged-in user who opens a reset link is bounced to the dashboard (`redirect_if_authenticated` on `edit`). | same |
| 8 | Low | Sessions have only an idle limit; no absolute lifetime. Changing a password from a reset kills all sessions (good), but there is no "change password while logged in" flow at all. | `Session`, `Authentication` |
| 9 | Cosmetic | `PasswordsMailer` subject is in English ("Reset your password"). | `app/mailers/passwords_mailer.rb` |

**Update:** all nine are fixed on this branch (first step, before the account-creation feature): explicit `users.superadmin` column + `dependent: :destroy` + unlinked accounts can't sign in (#1), `:passw`/`:email` log filtering (#2), `User` email/participant validations and a unique `participant_id` index (#3, #4), email resets gated by `config.x.password_reset_emails` and the email-only buttons replaced (#5), resets render their real errors and are rate-limited (#6), the reset link opens with a session open (#7), sessions capped at 90 days and a logged-in "Cambiar contraseña" page (#8), Spanish mailer (#9).

## 2. Proposed design: create an account from a profile

### Who
Roles allowed to create accounts (reuse the existing role vocabulary):
- `director` (the director couple), `coordinador`, `director_logistica`, and the superadmin.

This is the exact same set as `User#alert_manager?`, but it should get its **own** predicate (`account_manager?`) so the two permissions can diverge later.

**Decision for you:** should the logistics director create accounts for *anyone*, or only for their committee (`logistica`/`director_logistica`), mirroring how `can_edit_participant?` scopes them today? Recommendation: only their committee — it matches the rest of the permission model.

### Flow
1. On a participant's profile (`participants/show` and *Mi perfil*), the banner shows **"Crear cuenta"** when the viewer may manage accounts for that participant *and* `participant.user` is `nil`. If the account exists, show a small "Tiene cuenta: correo@…" badge instead (and optionally "Restablecer contraseña", see §5).
2. The button opens a `<dialog>` (existing `dialog` Stimulus controller, `data-dialog-name="account"`), with:
   - **Correo** — prefilled from the participant's contact email (`participant.email_address`, the `contact_info` jsonb).
   - **Confirmar correo** — empty, must match (the "double check").
   - A note: "La cuenta se crea con la contraseña predeterminada; se le pedirá cambiarla al entrar."
3. `POST /participants/:participant_id/account` creates the `User` with the default password and `must_change_password: true`, writes an audit entry, and redirects back to the profile with a notice that includes the email and the default password to hand over.
4. On the person's first login, every page redirects to **"Cambia tu contraseña"** until they set a new one (≠ default, passes the complexity rules, with confirmation). After that the flag is cleared, other sessions are closed, and they continue to where they were going.

### Security notes on the default password
A shared, known default password means anyone who knows a new user's email can log in first. Mitigations built into the design:
- Forced change on first login (the account is useless until changed).
- Keep the value out of the repo: read it from `ENV["DEFAULT_ACCOUNT_PASSWORD"]` / credentials, with `FsyManagua2026!` configured in `.kamal/secrets` / `config/deploy.yml` env. (If you prefer it in code, put it in one constant, `User::DEFAULT_PASSWORD`.)
- Optional: expire unused default passwords (e.g. reject login with the default after 7 days; an admin re-issues it). Needs `password_changed_at` instead of a boolean.
- The new password must differ from the default.
- *Accesos* can show "pendiente de cambiar contraseña" so the superadmin sees untouched accounts.

## 3. Blast radius

### New files
| File | Purpose |
|------|---------|
| `db/migrate/…_add_must_change_password_to_users.rb` | `must_change_password :boolean, default: false, null: false` (existing users unaffected). Optionally `password_changed_at :datetime`. |
| `db/migrate/…_make_users_participant_id_unique.rb` | Replace `index_users_on_participant_id` with a unique one (check for duplicates first). |
| `db/migrate/…_add_superadmin_to_users.rb` *(fix #1, recommended)* | Explicit `superadmin :boolean, default: false, null: false`, backfilled `true` for the current `participant_id IS NULL` account(s). |
| `app/controllers/participant_accounts_controller.rb` | `create` (and optional `reset`). Loads participant, checks `can_create_account_for?`, builds the user, audits. |
| `app/controllers/password_changes_controller.rb` | `edit` / `update` for the forced (and voluntary) change while logged in. |
| `app/views/participants/profile/_account_dialog.html.erb` | The modal with email + confirmation. |
| `app/views/password_changes/edit.html.erb` | Uses the `auth` layout and the existing `shared/password_field` partial with `rules: true`. |
| `test/controllers/participant_accounts_controller_test.rb`, `test/controllers/password_changes_controller_test.rb` | Permissions per role, duplicate email, mismatched confirmation, forced redirect, change flow. |

### Modified files
| File | Change |
|------|--------|
| `config/routes.rb` | `resources :participants do resource :account, only: :create, controller: "participant_accounts", path: "cuenta" end` and `resource :password_change, only: %i[edit update], path: "cambiar-contrasena"`. |
| `app/models/user.rb` | `account_manager?`; `validates :email_address, presence:, uniqueness:, format: URI::MailTo::EMAIL_REGEXP`; `validates :email_address, confirmation: true, on: :create`; `DEFAULT_PASSWORD` constant/ENV; `self.create_for_participant!(participant, email:)`; `password_change_required?`; validation that the new password ≠ default. Fix #1: `superadmin?` reads the new column; `full_access?`, `alert_manager?`, `agenda_manager?` stop using `participant_id.nil?`. |
| `app/models/participant.rb` | `has_one :user, dependent: :destroy` (fix #1 — removing the participant removes the login; alternatively keep `:nullify` once `superadmin` is a column). |
| `app/controllers/concerns/authentication.rb` | New `before_action :require_password_change` after `require_authentication`: if `Current.user.must_change_password?` redirect HTML requests to `edit_password_change_path`, answer `head :forbidden` for JSON/Turbo-stream/fetch endpoints (notification bell, push subscription, check-in roster). Class method `allow_pending_password_change` to skip it in `SessionsController#destroy` and `PasswordChangesController`. Also don't save the change page as `return_to`. |
| `app/controllers/concerns/authorization.rb` | `can_create_account_for?(participant)` (`account_manager?`, `participant.user.nil?`, and the director_logistica scope if you choose it); register in `helper_method`. |
| `app/controllers/sessions_controller.rb` | After `start_new_session_for`, send to `edit_password_change_path` when the flag is set (the before_action also covers it). `destroy` must skip the forced-change filter so a user can always log out. |
| `app/controllers/passwords_controller.rb` | On a successful reset, clear `must_change_password`. Fix #6 (render `:edit, status: :unprocessable_entity`) while there. |
| `app/views/participants/profile/_profile_banner.html.erb` | "Crear cuenta" button + render the dialog; "Tiene cuenta" badge otherwise. |
| `app/views/settings/show.html.erb` | Add "Cambiar contraseña" (link to the new page) — the email-reset button is useless until SMTP exists. |
| `app/views/participants/form/_form_actions.html.erb` | Hide/replace "Enviar enlace para restablecer contraseña" while email is disabled. |
| `app/views/sessions/new.html.erb` | Footer copy already says the account is created by coordination; consider hiding "¿Olvidaste tu contraseña?" until email exists ("pídele a tu coordinación que la restablezca"). |
| `app/models/audit_log.rb` | New category `cuentas` (+ label "Cuentas") so creation/reset is logged with who did it. |
| `app/views/accesses/index.html.erb` *(optional)* | Mark accounts still on the default password. |
| `config/initializers/filter_parameter_logging.rb` | Restore `:passw, :email` (fix #2). |
| `config/deploy.yml`, `.kamal/secrets` | `DEFAULT_ACCOUNT_PASSWORD` env, if taken out of code. |
| `test/fixtures/users.yml`, `test/models/user_test.rb`, `test/controllers/sessions_controller_test.rb`, `test/controllers/authorization_chain_test.rb` | Fixture for a user pending change; superadmin column; forced-redirect and logout-still-works tests. |
| `lib/demo_seed.rb` | It nulls `participant_id` on every user during reseed (`update_all(participant_id: nil)`), which today makes them all superadmins mid-run; adjust once `superadmin` is a column. |
| `CLAUDE.md` | Document the account flow and the new permission. |

### Not affected
Companies, inventory, finances, reports, agenda and dashboard logic. They only read `Current.user`; they change only indirectly if fix #1 replaces `participant_id.nil?` with a real `superadmin` column (7 call sites use `superadmin?`, and `full_access?` and its siblings check `participant_id.nil?` directly).

## 4. Suggested order of work
1. Fix #2 (log filtering): one line, no risk.
2. Fix #1 (explicit superadmin + `dependent`) with a migration and tests.
3. `User` validations + unique `participant_id` index (#3, #4).
4. `must_change_password` migration, `PasswordChangesController`, `Authentication` filter.
5. `ParticipantAccountsController`, authorization predicate, banner button + dialog, audit.
6. UI clean-up of email-dependent buttons; tests; CLAUDE.md.

## 5. Optional follow-up while there is no email
"Restablecer a contraseña predeterminada" for the same roles, on profiles that already have an account: sets the default password again, `must_change_password = true`, destroys that user's sessions, and writes an audit entry. It covers "forgot my password" without SMTP and reuses all the pieces above.

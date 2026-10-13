# Política de seguridad de contenido: el navegador solo corre los scripts de la app (los del importmap y el
# del <head>, con su nonce). Si algo se cuela en una página, como un nombre con código adentro, no se ejecuta.
# Solo se limita lo que corre código: estilos, imágenes (R2), fuentes y conexiones quedan como estaban.
# Más info: https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.script_src :self
    policy.object_src :none
    policy.base_uri :self
    policy.frame_ancestors :self
  end

  # El nonce es el de la sesión, como sugiere Rails: así Turbo, que no recarga el <head> entre páginas, sigue
  # aceptando sus scripts. Sin sesión todavía (la primera visita), uno al azar.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s.presence || SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.content_security_policy_nonce_auto = true
end

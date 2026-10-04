require Rails.root.join("config/apps_script_mail")

# El método de entrega :apps_script (lib/apps_script_delivery.rb), que production.rb elige cuando hay
# MAIL_RELAY_URL y MAIL_RELAY_SECRET (config/mail_delivery.rb).
ActiveSupport.on_load(:action_mailer) do
  add_delivery_method :apps_script, AppsScriptDelivery, AppsScriptMail.settings
end

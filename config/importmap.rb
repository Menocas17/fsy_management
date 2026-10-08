# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# Pesados y de pocas pantallas: sin modulepreload, sus controladores los importan cuando hacen falta.
pin "apexcharts", preload: false # @7.3.0
pin "apexcharts/core", to: "apexcharts--core.js", preload: false # @7.3.0
pin "jsqr", preload: false # @1.4.0
# La subida directa de la foto de perfil (avatar_preview_controller.js); viene con Rails.
pin "@rails/activestorage", to: "activestorage.esm.js", preload: false
pin_all_from "app/javascript/lib", under: "lib"

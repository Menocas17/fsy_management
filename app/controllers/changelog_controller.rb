# Novedades (/novedades): lo que ha cambiado en la app, la más nueva arriba (config/changelog.yml).
class ChangelogController < ApplicationController
  def index
    @entries = ChangelogEntry.visible_to(Current.user.participant)
  end
end

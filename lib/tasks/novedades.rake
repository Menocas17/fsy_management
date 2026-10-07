namespace :novedades do
  desc "Anuncia en la campanita las novedades de config/changelog.yml que todavía no se anunciaron"
  task anunciar: :environment do
    announced = ChangelogEntry.announce_pending!
    puts announced.any? ? "Anunciadas: #{announced.map(&:title).join(", ")}" : "No hay novedades por anunciar."
  end
end

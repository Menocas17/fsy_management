# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end

# pluralize(count, "inventario") usa el inflector del idioma de la app (es) y no había reglas: dejaba
# «4 inventario · 17 artículo». Reglas básicas del español: vocal + s, consonante + es (y la z pasa a c).
ActiveSupport::Inflector.inflections(:es) do |inflect|
  inflect.plural(/([aeiouáéíóú])$/i, '\1s')
  inflect.plural(/([^aeiouáéíóús])$/i, '\1es')
  inflect.plural(/z$/i, "ces")
  inflect.irregular "joven", "jóvenes"
end

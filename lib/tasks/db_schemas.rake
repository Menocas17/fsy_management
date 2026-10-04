# En producción cache, cola y cable comparten la base de la primaria, cada una en su propio esquema
# (config/database.yml). db:prepare no crea esquemas, así que se crean aquí justo antes. En desarrollo y
# pruebas ninguna base usa schema_search_path y esto no hace nada.
namespace :db do
  task create_schemas: :load_config do
    configs = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env)
    schemas = configs.filter_map { |config| config.configuration_hash[:schema_search_path] }.uniq
    next if schemas.empty?

    primary = configs.find { |config| config.name == "primary" }
    created = false
    begin
      ActiveRecord::Base.establish_connection(primary)
      schemas.each { |schema| ActiveRecord::Base.connection.create_schema(schema, if_not_exists: true) }
    rescue ActiveRecord::NoDatabaseError
      raise if created
      ActiveRecord::Tasks::DatabaseTasks.create(primary)
      created = true
      retry
    end
  end
end

Rake::Task["db:prepare"].enhance([ "db:create_schemas" ])

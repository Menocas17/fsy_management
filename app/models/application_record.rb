class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Los ids son UUID (aleatorios): sin esto, .first y .last ordenan por id y devuelven cualquier registro.
  # Con created_at (y el id para desempatar) «el último» es el último creado.
  self.implicit_order_column = [ "created_at", "id" ]
end

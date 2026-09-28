class ChangeIdentityDocumentToString < ActiveRecord::Migration[8.1]
  # La cédula nicaragüense (001-010190-0001A) tiene 13 dígitos y una letra: no cabe en un entero de 4
  # bytes y la letra se perdía. Se guarda como texto, en mayúsculas y sin guiones ni espacios.
  def up
    change_column :participants, :identity_document, :string
  end

  def down
    execute "UPDATE participants SET identity_document = NULL WHERE identity_document !~ '^[0-9]{1,9}$'"
    change_column :participants, :identity_document, :integer, using: "identity_document::integer"
  end
end

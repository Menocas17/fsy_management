class AddDetailsToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :number, :integer
    add_column :companies, :nickname, :string
    add_column :companies, :dining_hall, :integer

    # Backfill the fixed number from names like "Compañía 12", skipping names with no number or a repeated one.
    reversible do |dir|
      dir.up do
        execute <<~'SQL'
          UPDATE companies SET number = parsed.number
          FROM (
            SELECT id, substring(name from '(\d+)')::integer AS number,
                   count(*) OVER (PARTITION BY substring(name from '(\d+)')) AS repeats
            FROM companies
            WHERE name ~ '\d'
          ) parsed
          WHERE companies.id = parsed.id AND parsed.repeats = 1
        SQL
      end
    end

    add_index :companies, :number, unique: true
  end
end

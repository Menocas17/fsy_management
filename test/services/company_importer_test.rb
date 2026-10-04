require "test_helper"

class CompanyImporterTest < ActiveSupport::TestCase
  test "creates the companies with their auxiliar company and dining hall, and updates the ones that exist" do
    existing = Company.create!(number: 2)

    result = import_csv [ "Número,Compañía auxiliar,Comedor",
                          "1,Alfa,Salón Nicaragua",
                          "2,Auxiliar Alfa,Las Américas",
                          "Compañía 3,Beta,",
                          "x,Beta,",
                          "4,,Salón Marte" ]

    assert_equal [ 2, 1 ], [ result.created, result.updated ]
    assert_equal [ [ 5, "«x» no es un número de compañía" ], [ 6, "El comedor «Salón Marte» no existe" ] ], result.errors
    alfa = AuxiliarCompany.find_by!(name: "Auxiliar Alfa")
    assert_equal [ alfa, "salon_las_americas" ], [ existing.reload.auxiliar_company, existing.dining_hall ]
    assert_equal "Compañía 3", Company.find_by!(number: 3).name
    assert_equal [ "Auxiliar Alfa", "Auxiliar Beta" ], AuxiliarCompany.order(:name).pluck(:name)
  end

  test "without a Número column nothing is read" do
    assert_match "Número", import_csv([ "Nombre,Comedor", "Uno,Salón Nicaragua" ]).fatal
  end

  private
    def import_csv(lines)
      Tempfile.create([ "companias", ".csv" ]) do |file|
        file.write(lines.join("\n"))
        file.flush
        CompanyImporter.new(file.path).call
      end
    end
end

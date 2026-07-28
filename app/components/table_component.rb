
class TableComponent < ViewComponent::Base
  def initialize(participants:, is_staff: nil)
    @participants = participants
    @is_staff = is_staff
  end

  def show_cell
    if @is_staff
      "hidden lg:table-cell"
    else
      ""
    end
  end
end

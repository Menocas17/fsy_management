
class TableComponent < ViewComponent::Base
  delegate :icon, to: :helpers

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

  def from_path
    if @is_staff
      "staff"
    else
      "jovenes"
    end
  end

  def isAdmin?
    Current.user&.admin_or_staff_manager?
  end
end

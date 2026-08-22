
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

  def stake_color(participant)
    case participant.stake
    when "bello_horizonte"
      "bg-cyan-100"

    when "las_americas"
      "bg-indigo-100"

    when "villa_flor"
      "bg-green-100"

    when "puerto_cabezas"
      "bg-amber-100"
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

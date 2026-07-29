class RoleSpanComponent < ViewComponent::Base
  def initialize(role:)
    @role = role
  end

  def styles
    case @role
    when "joven"
        "bg-green-100"

    when "consejero"
        "bg-yellow-100"

    when "auxiliar"
        "bg-blue-100"

    when "coordinador"
        "bg-red-100"

    when "director"
        "bg-violet-100"

    when "logistica"
        "bg-cyan-100"

    when "registrador"
        "bg-red-100"
    end
  end
end

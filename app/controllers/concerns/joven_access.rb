# Lo que abre un joven: su inicio, la agenda, su compañía, su ficha y su QR, sus avisos, las novedades y su
# configuración. Todo lo demás es del staff (listas, fichas ajenas, compañías, logística, reportes…) y lo
# devuelve a su inicio. Es una lista de lo permitido: un controlador nuevo queda cerrado para los jóvenes
# hasta que declare `allow_jovenes`.
module JovenAccess
  extend ActiveSupport::Concern

  NOTICE = "Esa parte de la app es para el staff.".freeze

  included do
    class_attribute :joven_actions, instance_writer: false, default: [].freeze
    before_action :keep_jovenes_in_their_area
  end

  class_methods do
    # allow_jovenes abre todo el controlador; allow_jovenes only: %i[show] solo esas acciones.
    def allow_jovenes(only: nil)
      self.joven_actions = only ? only.map(&:to_s).freeze : :all
    end
  end

  private
    def joven_signed_in?
      Current.user&.participant&.joven? || false
    end

    def keep_jovenes_in_their_area
      return unless joven_signed_in?
      return if joven_actions == :all || joven_actions.include?(action_name)

      redirect_to dashboard_path, alert: NOTICE
    end
end

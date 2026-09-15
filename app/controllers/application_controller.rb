class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include Auditable
  include Pagy::Method
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Pagy keeps its own thread-local locale, separate from Rails' I18n.
  before_action { Pagy::I18n.locale = I18n.locale }
end

class NotificationsController < ApplicationController
  def index
    scope = Alert.visible_to(Current.user&.participant)
    @pagy, @alerts = pagy(scope.includes(images_attachments: :blob).recent)
    Current.user&.update_column(:alerts_read_at, Time.current)
  end
end

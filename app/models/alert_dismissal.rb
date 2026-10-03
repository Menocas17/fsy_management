# One person removed one alert from their own bell; everyone else still sees it.
class AlertDismissal < ApplicationRecord
  belongs_to :user
  belongs_to :alert
end

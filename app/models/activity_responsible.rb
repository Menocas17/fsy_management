class ActivityResponsible < ApplicationRecord
  belongs_to :activity
  belongs_to :participant

  validates :participant_id, uniqueness: { scope: :activity_id }
end

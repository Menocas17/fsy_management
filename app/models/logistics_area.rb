# A team inside Logística (Finanzas, Tecnología, Decoración…). Members are participants with rol "logistica".
class LogisticsArea < ApplicationRecord
  has_many :members, class_name: "Participant", dependent: :nullify

  validates :name, presence: true, uniqueness: true
end

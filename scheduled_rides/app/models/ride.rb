class Ride < ApplicationRecord

  belongs_to :scheduled_ride, optional: true
  belongs_to :user
  belongs_to :driver

end

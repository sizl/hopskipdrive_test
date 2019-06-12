class PropagateRidesJob < ApplicationJob
  queue_as :default

  def perform(scheduled_ride)

    # todo: create future rides based on repeat schedule setting

  end
end

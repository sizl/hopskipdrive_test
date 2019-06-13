class ScheduledRidesController < ApplicationController
  before_action :authenticate_user!

  def new
    #show scheduled ride form
  end

  def create
    scheduled_ride = current_user.scheduled_rides.create!(scheduled_rides_params)
    PropagateRidesJob.perform_later(scheduled_ride)
    render json: { message: 'scheduled ride was created' }
  end

  def update
    scheduled_ride = current_user.scheduled_rides.find(params[:id])

    if scheduled_ride.update(scheduled_rides_params)
      PropagateRidesJob.perform_later(scheduled_ride)
    end

    render json: { message: 'Schedule was updated' }
  end

  def scheduled_rides_params
    params.require(:scheduled_ride).permit(:pickup_time, :name, :start_address, :end_address, :repeat_type, :repeat_value, :ends_at)
  end

end

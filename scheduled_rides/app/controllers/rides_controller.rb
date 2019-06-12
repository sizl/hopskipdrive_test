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
    ride = current_user.rides.find(params[:id])
    ride.update(rides_params)

    if ride.scheduled_ride_id.present?
      PropagateRidesJob.perform_later(ride.scheduled_ride)
    end

    render json: { message: 'Schedule was updated' }
  end

  def rides_params
    params.require(:scheduled_ride).permit(:pickup_time, :start_address, :end_address)
  end

end

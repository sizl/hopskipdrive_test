Rails.application.routes.draw do

  resources :scheduled_rides do

  end

  resourced :rides do

    post '/:id/cancel', to: 'rides#cancel'
  end

end

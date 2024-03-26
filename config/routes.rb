Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :user
      resources :hotel
      resources :booking
      get '/my-bookings', to: 'booking#index'
      post '/book', to: 'booking#book_hotel'
      get '/bookings', to: 'booking#booked_hotels'
    end
  end

end

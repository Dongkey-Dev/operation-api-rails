Rails.application.routes.draw do
  mount OasRails::Engine => "/api-docs"

  namespace :api do
    namespace :v1 do
      # Command resources - with scopes for filtering
      resources :commands

      # Command Response resources - with scopes for filtering
      resources :command_responses

      resources :room_user_nickname_histories
      resources :room_user_events
      resources :room_users
      resources :chat_messages
      resources :room_features
      resources :features
      resources :room_plan_histories
      resources :plans
      resources :operation_rooms
      resources :customer_admin_rooms
      resources :customers
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end

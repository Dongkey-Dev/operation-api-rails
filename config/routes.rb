Rails.application.routes.draw do
  mount OasRails::Engine => "/api-docs"

  namespace :api do
    namespace :v1 do
      # Command resources with custom endpoints
      resources :commands do
        collection do
          get 'customer/:id', to: 'commands#by_customer', as: 'by_customer'
          get 'room/:id', to: 'commands#by_operation_room', as: 'by_operation_room'
          get 'active', to: 'commands#active'
          get 'active/customer/:id', to: 'commands#active_by_customer', as: 'active_by_customer'
          get 'active/room/:id', to: 'commands#active_by_operation_room', as: 'active_by_operation_room'
        end
        member do
          put 'toggle_active', to: 'commands#toggle_active'
        end
      end
      
      # Command Response resources with custom endpoints
      resources :command_responses do
        collection do
          get 'by_command/:id', to: 'command_responses#by_command', as: 'by_command'
          get 'active', to: 'command_responses#active'
          get 'active/by_command/:id', to: 'command_responses#active_by_command', as: 'active_by_command'
        end
        member do
          put 'toggle_active', to: 'command_responses#toggle_active'
        end
      end
      
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

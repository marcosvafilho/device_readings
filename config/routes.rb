Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "readings", to: "readings#create"

      get "devices/:id/latest_timestamp", to: "devices#latest_timestamp"
      get "devices/:id/cumulative_count", to: "devices#cumulative_count"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

Rails.application.routes.draw do
  get "home/index"
  root "home#index"
  get "registrations/new"
  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token

  # Hospital resources
  resources :doctors do
    member do
      patch :assign_nurse
      patch :unassign_nurse
    end
  end
  resources :nurses
  resources :patients do
    member do
      patch :discharge
    end
  end
  resources :rooms
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :api do
    get "charts/dashboard_stats"
    get "charts/patient_admissions"
    get "charts/patient_trend"
    get "charts/room_occupancy"
    get "charts/patient_conditions"
    get "charts/staff_workload"
    get "charts/monthly_trends"
    get "charts/doctor_specialties"
    get "doctors/:id/nurses", to: "doctors#nurses"
    get "nurses/available", to: "nurses#available"
  end

  # Defines the root path route ("/")
  # root "posts#index"
end

# config/routes.rb
Rails.application.routes.draw do
  resources :courses do
    resources :enrolled_students, only: [ :index, :create, :destroy ]
    delete "clear_enrolled_students", to: "enrolled_students#destroy_all", on: :member
    resources :checkin_forms, only: [ :index, :new, :create, :show, :destroy ] do
      member do
        patch :toggle
        get :qr_code
        get :fullscreen
      end
    end
    member do
      get :dashboard
      get :export_attendance
    end
  end

  # Student Dashboard
  get "student/dashboard", to: "student_dashboard#index", as: :student_dashboard

  # Checkin - URL เดียว
  get "checkin/:token", to: "checkins#new", as: :checkin
  post "checkin/:token", to: "checkins#create"
  # ลบ success route ออก

  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user, ->(u) { u.teacher? } do
    root "courses#index", as: :teacher_root
  end

  authenticated :user, ->(u) { u.student? } do
    root "student_dashboard#index", as: :student_root
  end

  devise_scope :user do
    root "devise/sessions#new"
  end
end

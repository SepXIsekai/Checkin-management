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

  # Checkin
  get "checkin/:token", to: "checkins#new", as: :checkin
  post "checkin/:token", to: "checkins#create"
  get "checkin/:token/success", to: "checkins#success", as: :checkin_success

  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  # Root ตาม role
  authenticated :user, ->(u) { u.teacher? } do
    root "courses#index", as: :teacher_root
  end

  authenticated :user, ->(u) { u.student? } do
    root "student_dashboard#index", as: :student_root
  end

  # ยังไม่ login ไปหน้า login
  devise_scope :user do
    root "devise/sessions#new"
  end
end

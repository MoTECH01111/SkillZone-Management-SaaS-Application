Rails.application.routes.draw do
  # Custom employee lookup
  get '/employees/find_by_email', to: 'employees#find_by_email'

  # Employee management
  resources :employees

  # Courses: employees can view, admins can create/update/delete
  resources :courses do
    # Employees can view or create enrollments for a specific course
    resources :enrollments, only: [:index, :create], shallow: true
  end

  # Standalone enrollments for admins to manage any enrollment
  resources :enrollments, only: [:show, :update, :destroy]

  # Certificates: admins create/update/delete, employees view
  resources :certificates, only: [:index, :show, :create, :update, :destroy]
end

Rails.application.routes.draw do # Defines all HTTP routes
  # Custom GET route to retrieve employee email
  get "/employees/find_by_email", to: "employees#find_by_email"

  # Creates the standard routes index, show, create,update,destroy
  resources :employees do
    collection do   # Creates a custom collection Route
      post :login
    end
  end
  #  Creates Courses routes Create, view, update, and delete courses
  resources :courses do
    # Nested enrollments
    resources :enrollments, only: [ :index, :create, :show, :update, :destroy ]
  end

  resources :enrollments # Enrollments routes index, show, create,update,destroy

  # Certificates routes index, show, create,update,destroy
  resources :certificates
end

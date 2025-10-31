Rails.application.routes.draw do
  resources :employees
  resources :courses
  resources :enrollments
  resources :certificates
  root "employees#index"
end

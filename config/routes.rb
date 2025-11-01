Rails.application.routes.draw do
  resources :employees
  resources :courses
  resources :enrollments
  resources :certificates
end

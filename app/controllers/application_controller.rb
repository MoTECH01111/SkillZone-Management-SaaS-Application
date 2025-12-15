class ApplicationController < ActionController::API # Base controller for the API
  before_action :set_current_employee_from_param # Ensures current_employee is available for controllers

  attr_reader :current_employee # Allows other controllers to access the employee without changing it

  private
  # Retrieves the employee record using employee_id
  def set_current_employee_from_param
    @current_employee = Employee.find_by(id: params[:employee_id])
  end

  # Global admin check for all controllers
  def require_admin
    unless current_employee&.admin?
      render json: { error: "Admins only" }, status: :forbidden
    end
  end
end

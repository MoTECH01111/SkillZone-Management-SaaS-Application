class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :update, :destroy]
  before_action :require_admin, only: [:index, :destroy]
  before_action :authorize_update, only: [:update]

  # GET /employees
  # Admins can see all employees
  def index
    employees = Employee.all
    render json: employees, status: :ok
  end

  # GET /employees/:id
  def show
    if @employee
      render json: @employee, status: :ok
    else
      render json: { error: "Employee not found" }, status: :not_found
    end
  end

  # POST /employees
  # Both admin and employees can create an account
  def create
    employee = Employee.new(employee_params)
    if employee.save
      render json: employee, status: :created
    else
      render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /employees/:id
  # Admins can update anyone; employees can only update their own profile
  def update
    if @employee.update(employee_params)
      render json: @employee, status: :ok
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /employees/:id
  # Only admins can delete employees
  def destroy
    if @employee
      @employee.destroy
      head :no_content
    else
      render json: { error: "Employee not found" }, status: :not_found
    end
  end

  private

  # Set employee for show, update, destroy
  def set_employee
    @employee = Employee.find_by(id: params[:id])
  end

  # Strong parameters
  def employee_params
    params.require(:employee).permit(
      :first_name, :last_name, :email, :phone,
      :position, :department, :gender, :hire_date
    )
  end

  # Restrict certain actions to admins only
  def require_admin
    unless current_employee&.admin?
      render json: { error: "Access denied. Admins only." }, status: :forbidden
    end
  end

  # Employees can only update their own profile
  def authorize_update
    unless current_employee&.admin? || current_employee == @employee
      render json: { error: "Access denied. You can only update your own profile." }, status: :forbidden
    end
  end

  # Allow stubbing in tests
  def current_employee
    @current_employee ||= super if defined?(super)
  end
end

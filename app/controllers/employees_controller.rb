class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :update, :destroy]
  before_action :require_admin, except: [:index, :show]

  # GET /employees
  def index
    employees = Employee.all
    render json: employees, status: :ok
  end

  # GET /employees/:id
  def show
    render json: @employee, status: :ok
  end

  # POST /employees
  def create
    employee = Employee.new(employee_params)
    if employee.save
      render json: employee, status: :created
    else
      render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /employees/:id
  def update
    if @employee.update(employee_params)
      render json: @employee, status: :ok
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /employees/:id
  def destroy
    @employee.destroy
    head :no_content
  end

  private

  # Set the employee for show, update, destroy
  def set_employee
    @employee = Employee.find(params[:id])
  end

  # Strong parameters
  def employee_params
    params.require(:employee).permit(
      :first_name, :last_name, :email, :phone, :position,
      :department, :gender, :hire_date
    )
  end

  # Restrict admin-only actions
  def require_admin
    unless current_employee&.admin?
      render json: { error: "Access denied. Admins only." }, status: :forbidden
    end
  end

  # Allow current_employee to be stubbed in tests
  def current_employee
    @current_employee ||= super if defined?(super)
  end
end

class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, except: [:index, :show] # only admins can modify employees

  # GET /employees
  def index
    @employees = Employee.all
  end

  # GET /employees/:id
  def show
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # POST /employees
  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to @employee, notice: "Employee was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /employees/:id/edit
  def edit
  end

  # PATCH/PUT /employees/:id
  def update
    if @employee.update(employee_params)
      redirect_to @employee, notice: "Employee was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /employees/:id
  def destroy
    @employee.destroy
    redirect_to employees_path, notice: "Employee was successfully deleted."
  end

  private

  # Set the employee for show, edit, update, destroy
  def set_employee
    @employee = Employee.find(params[:id])
  end

  # Strong parameters for employee
  def employee_params
    params.require(:employee).permit(
      :first_name, :last_name, :email, :phone, :position,
      :department, :gender, :hire_date
    )
  end

  # Restrict admin-only actions
  def require_admin
    unless current_employee&.admin?
      redirect_to employees_path, alert: "Access denied. Admins only."
    end
  end

  # Allow current_employee to be stubbed in tests
  def current_employee
    @current_employee ||= super if defined?(super)
  end
end

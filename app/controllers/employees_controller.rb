class EmployeesController < ApplicationController # Employee Controller API for role access control
  # Handles employee registration, authentication, profile and admin contol
  before_action :set_employee, only: [ :show, :update, :destroy ] # Load employee using show, update, destroy
  before_action :set_current_employee_from_param # Current logged in employee / Used for authorization
  before_action :require_admin, only: [ :index, :destroy ] # Set admin actions restricted for other
  before_action :authorize_update, only: [ :update ] # Only admins can update all employees and employee update themselves.


  # Admin endpoint for retrieving all employee
  # GET /employees
  def index
    render json: Employee.all, status: :ok
  end


  # POST /employees/login
  # Uses the employee email and hire date to login
  def login
    email = params[:email]&.downcase # ensure the email is downcase to prevent case sensitive issue
    hire_date_raw = params[:hire_date]

    employee = Employee.find_by(email: email) # Find the employee by email

    unless employee # Throws an error if email is invalid
      return render json: { error: "Invalid email" }, status: :unauthorized
    end

    begin # Correct the date format for how employee table
      provided_date = Date.parse(hire_date_raw).strftime("%Y-%m-%d")
      employee_date = employee.hire_date.strftime("%Y-%m-%d")
    rescue
      return render json: { error: "Invalid date format" }, status: :unprocessable_entity # Throws an error if date format is invalid
    end

    if provided_date == employee_date # Checks that employee hire date match
      render json: employee, status: :ok
    else
      render json: { error: "Incorrect hire date" }, status: :unauthorized  # Throws an error if Incorrect hire date is wrong
    end
  end

  # Retrieves one employee record
  # GET /employees/:id
  def show
    if @employee
      render json: @employee, status: :ok
    else
      render json: { error: "Employee not found" }, status: :not_found
    end
  end

  # This allows new employee to create their account
  # POST /employees
  def create
    employee = Employee.new(employee_params)

    if employee.save
      render json: employee, status: :created
    else
      render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Admin can edit anyone; employees can edit themselves
  # PATCH/PUT /employees/:id
  def update
    if @employee.update(employee_params)
      render json: @employee, status: :ok
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Delete function only admin can use this function
  # DELETE /employees/:id
  def destroy
    unless @employee
      return render json: { error: "Employee not found" }, status: :not_found
    end

    @employee.destroy
    head :no_content # Return empty response on delete
  end

  # Private helper
  private

  # Load employee for show, update and delete
  def set_employee
    @employee = Employee.find_by(id: params[:id])
  end

  # Retrieves the current employee logged in
  # employee_id is passed as a request param
  def set_current_employee_from_param
    @current_employee = Employee.find_by(id: params[:employee_id])
  end

  # Checks if only Admin users can access certain functions
  def require_admin
    unless @current_employee&.admin?
      render json: { error: "Admins only" }, status: :forbidden
    end
  end

  # Gives access to employee to update their own information and Admins to update any employee information
  def authorize_update
    return if @current_employee&.admin?
    return if @current_employee&.id == @employee&.id

    render json: { error: "Access denied" }, status: :forbidden
  end

 # Strong parameters
 def employee_params
    permitted = [
      :first_name,
      :last_name,
      :email,
      :phone,
      :position,
      :department,
      :gender,
      :hire_date
    ]

    # Only allow admin flag if current user is an admin
    permitted << :admin if @current_employee&.admin?

    params.require(:employee).permit(permitted)
  end
end

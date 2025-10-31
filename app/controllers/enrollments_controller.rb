class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, except: [:index, :show]  # only admins can modify

  # GET /enrollments
  def index
    @enrollments = Enrollment.includes(:employee, :course)
  end

  # GET /enrollments/:id
  def show; end

  # GET /enrollments/new
  def new
    @enrollment = Enrollment.new
    @employees = Employee.all
    @courses = Course.all
  end

  # POST /enrollments
  def create
    @enrollment = Enrollment.new(enrollment_params)
    if @enrollment.save
      redirect_to @enrollment, notice: 'Enrollment created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /enrollments/:id/edit
  def edit
    @employees = Employee.all
    @courses = Course.all
  end

  # PATCH/PUT /enrollments/:id
  def update
    if @enrollment.update(enrollment_params)
      redirect_to @enrollment, notice: 'Enrollment updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /enrollments/:id
  def destroy
    @enrollment.destroy
    redirect_to enrollments_url, notice: 'Enrollment deleted successfully.'
  end

  private

  def set_enrollment
    @enrollment = Enrollment.find(params[:id])
  end

  def enrollment_params
    params.require(:enrollment).permit(:employee_id, :course_id, :status, :progress, :completed_on)
  end

  # Restrict admin-only actions
  def require_admin
    unless current_employee&.admin?
      redirect_to enrollments_path, alert: 'Access denied. Admins only.'
    end
  end
end

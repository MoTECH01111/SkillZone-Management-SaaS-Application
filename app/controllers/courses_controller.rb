class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :update, :destroy, :enroll]
  before_action :require_admin, except: [:index, :show, :enroll]

  # GET /courses
  def index
    courses = Course.all
    render json: courses, status: :ok
  end

  # GET /courses/:id
  def show
    render json: @course, status: :ok
  end

  # POST /courses
  def create
    course = Course.new(course_params)
    if course.save
      render json: course, status: :created
    else
      render json: { errors: course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/:id
  def update
    if @course.update(course_params)
      render json: @course, status: :ok
    else
      render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /courses/:id
  def destroy
    @course.destroy
    head :no_content
  end

  # POST /courses/:id/enroll
  def enroll
    # Ensure only employees (non-admins) can enroll
    if current_employee&.admin?
      render json: { error: "Admins cannot enroll in courses." }, status: :forbidden
      return
    end

    enrollment = Enrollment.new(employee_id: current_employee.id, course_id: @course.id)

    if enrollment.save
      render json: { message: "Successfully enrolled in #{@course.title}" }, status: :created
    else
      render json: { errors: enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :duration_minutes, :capacity, :level, :start_date, :end_date)
  end

  def require_admin
    unless current_employee&.admin?
      render json: { error: "Access denied. Admins only." }, status: :forbidden
    end
  end
end

class CoursesController < ApplicationController # Course Controller API for function control
  before_action :set_course, only: [ :show, :update, :destroy ]
  before_action :require_admin, except: [ :index, :show ]

  # GET /courses
  # Employees and Admins can see all courses
  def index
    courses = Course.all
    render json: courses, status: :ok
  end

  # GET /courses/:id
  # Employees and Admins can view one course
  def show
    render json: @course, status: :ok
  end

  # POST /courses
  # Admin only can create a new course
  def create
    course = Course.new(course_params)

    if course.save
      render json: course, status: :created
    else
      render json: { errors: course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/:id
  # Admin only can  Update a course
  def update
    if @course.update(course_params)
      render json: @course, status: :ok
    else
      render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /courses/:id
  # Admin can only delete a course
  def destroy
    @course.destroy
    head :no_content
  end

  # Private helper
  private

  # Assigns the selected course
  def set_course
    @course = Course.find_by(id: params[:id])

    unless @course
      render json: { error: "Course not found" }, status: :not_found
    end
  end

  # Strong parameters
  def course_params
    params.require(:course).permit(
      :title,
      :description,
      :duration_minutes,
      :capacity,
      :level,
      :start_date,
      :end_date,
      :youtube_url,
      :department
    )
  end
end

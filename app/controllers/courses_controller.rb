class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, except: [:index, :show]  # only admin can modify

  def index
    @courses = Course.all
  end

  def show; end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to @course, notice: 'Course created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @course.update(course_params)
      redirect_to @course, notice: 'Course updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_url, notice: 'Course deleted successfully.'
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :duration_minutes, :capacity, :start_date, :end_date)
  end

  # Restrict admin-only actions
  def require_admin
    # current_employee comes from your authentication system
    unless current_employee&.admin?
      redirect_to courses_path, alert: 'Access denied. Admins only.'
    end
  end

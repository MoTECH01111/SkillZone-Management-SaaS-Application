class EnrollmentsController < ApplicationController # Enrollment API Controller for function control
  before_action :set_enrollment, only: [ :show, :update, :destroy ]

  # GET /enrollments set access for all enrollments
  def index
    @enrollments = Enrollment.includes(:employee, :course).all

    render json: @enrollments.as_json(
      include: {
        employee: { only: [ :id, :first_name, :last_name, :email ] },
        course:   { only: [ :id, :title, :description ] }
      },
      only: [
        :id,
        :status,
        :progress,
        :completed_on,
        :enrolled_on,
        :grade
      ]
    )
  end

  # GET /enrollments/:id This displays all courses
  def show
    render json: @enrollment.as_json(
      include: {
        employee: { only: [ :id, :first_name, :last_name, :email ] },
        course:   { only: [ :id, :title, :description ] }
      },
      only: [
        :id,
        :status,
        :progress,
        :completed_on,
        :enrolled_on,
        :grade
      ]
    )
  end

  # POST /enrollments Allows employee to enroll into a course
  def create
    @enrollment = Enrollment.new(enrollment_params)

    if @enrollment.save
      render json: @enrollment.as_json(
        include: {
          employee: { only: [ :id, :first_name, :last_name, :email ] },
          course:   { only: [ :id, :title, :description ] }
        },
        only: [
          :id,
          :status,
          :progress,
          :completed_on,
          :enrolled_on,
          :grade
        ]
      ), status: :created
    else
      render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /enrollments/:id Allows employee to update their enrollment
  def update
    if @enrollment.update(enrollment_params)
      render json: @enrollment.as_json(
        include: {
          employee: { only: [ :id, :first_name, :last_name, :email ] },
          course:   { only: [ :id, :title, :description ] }
        },
        only: [
          :id,
          :status,
          :progress,
          :completed_on,
          :enrolled_on,
          :grade
        ]
      )
    else
      render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /enrollments/:id This function allows employee to delete enrollments
  def destroy
    @enrollment.destroy
    head :no_content
  end

  private # Private helper

  def set_enrollment # Assigns enrollment
    @enrollment = Enrollment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Enrollment not found" }, status: :not_found
  end

  # Strong parameters
  def enrollment_params
    params.require(:enrollment).permit(
      :employee_id,
      :course_id,
      :status,
      :progress,
      :completed_on,
      :grade,
      :enrolled_on
    )
  end
end

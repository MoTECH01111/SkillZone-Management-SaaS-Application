class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: [:show, :update, :destroy]
  before_action :require_admin, except: [:index, :show]  # Only admins can modify

  # GET /enrollments
  def index
    @enrollments = Enrollment.includes(:employee, :course).all
    render json: @enrollments.as_json(
      include: {
        employee: { only: [:id, :first_name, :last_name, :email] },
        course: { only: [:id, :title, :description] }
      },
      except: [:created_at, :updated_at]
    )
  end

  # GET /enrollments/:id
  def show
    render json: @enrollment.as_json(
      include: {
        employee: { only: [:id, :first_name, :last_name, :email] },
        course: { only: [:id, :title, :description] }
      },
      except: [:created_at, :updated_at]
    )
  end

  # POST /enrollments
  def create
    @enrollment = Enrollment.new(enrollment_params)
    if @enrollment.save
      render json: @enrollment.as_json(
        include: {
          employee: { only: [:id, :first_name, :last_name, :email] },
          course: { only: [:id, :title, :description] }
        }
      ), status: :created
    else
      render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /enrollments/:id
  def update
    if @enrollment.update(enrollment_params)
      render json: @enrollment.as_json(
        include: {
          employee: { only: [:id, :first_name, :last_name, :email] },
          course: { only: [:id, :title, :description] }
        }
      ), status: :ok
    else
      render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /enrollments/:id
  def destroy
    @enrollment.destroy
    head :no_content
  end

  private

  def set_enrollment
    @enrollment = Enrollment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Enrollment not found" }, status: :not_found
  end

  def enrollment_params
    params.require(:enrollment).permit(:employee_id, :course_id, :status, :progress, :completed_on)
  end

  # Restrict admin-only actions
  def require_admin
    unless current_employee&.admin?
      render json: { error: "Access denied. Admins only." }, status: :forbidden
    end
  end
end

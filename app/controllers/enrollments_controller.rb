class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: [ :show, :update, :destroy ]
  before_action :authorize_action, only: [ :create, :update, :destroy ]

  # GET /enrollments
  def index
    @enrollments =
      if current_employee&.admin?
        Enrollment.includes(:employee, :course).all
      else
        Enrollment.includes(:employee, :course).where(employee_id: current_employee.id)
      end

    render json: @enrollments.as_json(
      include: {
        employee: { only: [ :id, :first_name, :last_name, :email ] },
        course: { only: [ :id, :title, :description ] }
      },
      except: [ :created_at, :updated_at ]
    )
  end

  # GET /enrollments/:id
  def show
    if current_employee&.admin? || @enrollment.employee_id == current_employee&.id
      render json: @enrollment.as_json(
        include: {
          employee: { only: [ :id, :first_name, :last_name, :email ] },
          course: { only: [ :id, :title, :description ] }
        },
        except: [ :created_at, :updated_at ]
      )
    else
      render json: { error: "Access denied." }, status: :forbidden
    end
  end

  # POST /enrollments
  def create
    @enrollment = Enrollment.new(enrollment_params)

    # Employees can only create their own enrollment
    unless current_employee&.admin? || @enrollment.employee_id == current_employee&.id
      return render json: { error: "You can only enroll yourself." }, status: :forbidden
    end

    if @enrollment.save
      render json: @enrollment.as_json(
        include: {
          employee: { only: [ :id, :first_name, :last_name, :email ] },
          course: { only: [ :id, :title, :description ] }
        }
      ), status: :created
    else
      render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /enrollments/:id
  def update
    # Employee can only update their own enrollment
    unless current_employee&.admin? || @enrollment.employee_id == current_employee&.id
      return render json: { error: "Access denied." }, status: :forbidden
    end

    if @enrollment.update(enrollment_params)
      render json: @enrollment.as_json(
        include: {
          employee: { only: [ :id, :first_name, :last_name, :email ] },
          course: { only: [ :id, :title, :description ] }
        }
      ), status: :ok
    else
      render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /enrollments/:id
  def destroy
    # Only admins can delete enrollments
    unless current_employee&.admin?
      return render json: { error: "Only admins can delete enrollments." }, status: :forbidden
    end

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

  def authorize_action
    return if current_employee.present?

    render json: { error: "You must be logged in." }, status: :unauthorized
  end
end

class CertificatesController < ApplicationController
  before_action :set_certificate, only: [:show, :update, :destroy]
  before_action :require_admin, only: [:create, :update, :destroy]

  # GET /certificates
  def index
    certificates = Certificate.includes(:employee, :course)
    render json: certificates.as_json(include: [:employee, :course]), status: :ok
  end

  # GET /certificates/:id
  def show
    render json: @certificate.as_json(include: [:employee, :course]), status: :ok
  end

  # POST /certificates
  def create
    certificate = Certificate.new(certificate_params)
    attach_document(certificate)

    if certificate.save
      render json: certificate, status: :created
    else
      render json: { errors: certificate.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /certificates/:id
  def update
    @certificate.assign_attributes(certificate_params)
    attach_document(@certificate)

    if @certificate.save
      render json: @certificate, status: :ok
    else
      render json: { errors: @certificate.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /certificates/:id
  def destroy
    @certificate.destroy
    head :no_content
  end

  private

  def set_certificate
    @certificate = Certificate.find(params[:id])
  end

  def certificate_params
    params.require(:certificate).permit(:name, :issued_on, :expiry_date, :employee_id, :course_id)
  end

  def attach_document(certificate)
    if params[:certificate][:document].present?
      certificate.document.attach(params[:certificate][:document])
    end
  end

  def require_admin
    unless current_employee&.admin?
      render json: { error: "Access denied. Admins only." }, status: :forbidden
    end
  end
end

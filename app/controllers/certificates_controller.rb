class CertificatesController < ApplicationController
  before_action :set_certificate, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, except: [:index, :show]  # only admins can modify

  # GET /certificates
  def index
    @certificates = Certificate.includes(:employee, :course)
  end

  # GET /certificates/:id
  def show; end

  # GET /certificates/new
  def new
    @certificate = Certificate.new
    @employees = Employee.all
    @courses = Course.all
  end

  # POST /certificates
  def create
    @certificate = Certificate.new(certificate_params)
    if @certificate.save
      redirect_to @certificate, notice: 'Certificate uploaded successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /certificates/:id/edit
  def edit
    @employees = Employee.all
    @courses = Course.all
  end

  # PATCH/PUT /certificates/:id
  def update
    if @certificate.update(certificate_params)
      redirect_to @certificate, notice: 'Certificate updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /certificates/:id
  def destroy
    @certificate.destroy
    redirect_to certificates_url, notice: 'Certificate deleted successfully.'
  end

  private

  def set_certificate
    @certificate = Certificate.find(params[:id])
  end

  def certificate_params
    params.require(:certificate).permit(:name, :issued_on, :expiry_date, :employee_id, :course_id, :document)
  end

  # Restrict admin-only actions
  def require_admin
    unless current_employee&.admin?
      redirect_to certificates_path, alert: 'Access denied. Admins only.'
    end
  end
end

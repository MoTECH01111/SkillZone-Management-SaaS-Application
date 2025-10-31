class CertificatesController < ApplicationController
  before_action :set_certificate, only: [:show, :update, :destroy]

  def index
    render json: Certificate.all
  end

  def show
    render json: @certificate
  end

  def create
    @certificate = Certificate.new(certificate_params)
    @certificate.document.attach(params[:certificate][:document]) if params[:certificate][:document].present?

    if @certificate.save
      render json: @certificate, status: :created
    else
      render json: { errors: @certificate.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @certificate.document.attach(params[:certificate][:document]) if params[:certificate][:document].present?

    if @certificate.update(certificate_params)
      render json: @certificate
    else
      render json: { errors: @certificate.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @certificate.destroy
    render json: { message: "Certificate deleted" }
  end

  private

  def set_certificate
    @certificate = Certificate.find(params[:id])
  end

  def certificate_params
    params.require(:certificate).permit(:employee_id, :course_id, :name, :issue_date, :expiry_date)
  end
end

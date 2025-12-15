class CertificatesController < ApplicationController # Cerificate Controller API for function control
  before_action :set_certificate, only: [:show, :update, :destroy] # Load all certificates for show ,update and destoy functions
  before_action :require_admin, only: [:create, :update, :destroy]

  # GET /certificates Retrieves all certificare assiocated with employee and course
  def index
    certificates = Certificate.includes(:employee, :course)

    render json: certificates.as_json( # Render all certificates in JSON format
      include: {
        employee: { only: [:id, :first_name, :last_name, :email] },
        course:   { only: [:id, :title, :level] }
      },
      methods: [:document_url], # retrieves document for file URL from active storage
      except: [:created_at, :updated_at]
    ), status: :ok
  end

  # GET /certificates/:id # Returns one certidicate with related employee and course details
  def show
    render json: @certificate.as_json(
      include: {
        employee: { only: [:id, :first_name, :last_name, :email] },
        course:   { only: [:id, :title, :level] }
      },
      methods: [:document_url], # retrieve document for file URL from active storage
      except: [:created_at, :updated_at]
    ), status: :ok
  end

  # POST /certificates Only admins can create a new certificate
  def create
    certificate = Certificate.new(certificate_params)
    attach_document(certificate)

    if certificate.save
      render json: certificate.as_json(
        methods: [:document_url],
        except: [:created_at, :updated_at]
      ), status: :created
    else
      render json: { errors: certificate.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /certificates/:id Only admins can update certificates
  def update
    @certificate.assign_attributes(certificate_params)
    attach_document(@certificate) # Attach uploaded document if present

    if @certificate.save
      render json: @certificate.as_json(
        methods: [:document_url],
        except: [:created_at, :updated_at]
      ), status: :ok
    else
      render json: { errors: @certificate.errors.full_messages }, status: :unprocessable_entity # Throw erros if creation has failed
    end 
  end

  # DELETE /certificates/:id
  def destroy
    @certificate.destroy
    head :no_content
  end

  private # Priavte helper

  def set_certificate #Finds the certificate specified by the URL Param
    @certificate = Certificate.find(params[:id])
  end

  #  Strong param for certificate creation and update
  def certificate_params
    params.require(:certificate).permit(
      :name,
      :description,
      :issued_on,
      :expiry_date,
      :employee_id,
      :course_id,
      :document
    )
  end

  # ActiveStorage document handling
  def attach_document(certificate)
    file = params.dig(:certificate, :document)
    return unless file.present?
    certificate.document.attach(file)
  end

  def require_admin #  only admin users can access protected functions
    unless current_employee&.admin?
      render json: { error: "Access denied. Admins only." }, status: :forbidden
    end
  end
end

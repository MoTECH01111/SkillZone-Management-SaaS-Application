class Certificate < ApplicationRecord # Certificate model
  # ASSOCIATIONS this model is need for both course and employee
  belongs_to :employee
  belongs_to :course
  # Declaring that model accepts a pdf
  has_one_attached :document

  # 6 VALIDATIONS

  # All these fields need to pesent for the certificate to be stored
  validates :name,       presence: true
  validates :description, presence: true
  validates :issued_on,  presence: true
  validates :expiry_date, presence: true,
                          comparison: {
                            greater_than: :issued_on,
                            message: "must be after the issued date"
                          }

  # Prevent issuance in the future
  validate :issued_on_cannot_be_in_the_future

  # Must attach PDF
  validate :document_must_be_attached

  # Url Helper 
  # This allows frontend to access PDF file
  def document_url
    return nil unless document.attached?

    # Get the ActiveStorage path
    path = Rails.application.routes.url_helpers.rails_blob_path(
      document,
      disposition: "inline",
      only_path: true
    )

    # Prepend full absolute URL
    "http://localhost:3000#{path}"
  end
  
  # Private helper 
  private

  # Issued date cannot be cannot be in the fute
  def issued_on_cannot_be_in_the_future
    return if issued_on.blank?

    if issued_on > Date.today
      errors.add(:issued_on, "can't be in the future")
    end
  end

  # A document must be attached for the certificate
  def document_must_be_attached
    unless document.attached?
      errors.add(:document, "must be attached")
    end
  end
end

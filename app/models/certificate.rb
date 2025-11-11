class Certificate < ApplicationRecord
  #  ASSOCIATIONS
  belongs_to :employee
  belongs_to :course

  # ATTACHMENTS 
  has_one_attached :document

  # VALIDATIONS
  validates :name, presence: true
  validates :issued_on, presence: true
  validates :expiry_date,
            presence: true,
            comparison: { greater_than: :issued_on, message: "must be after the issued date" }

  validate :issued_on_cannot_be_in_the_future
  validate :document_must_be_attached

  # CUSTOM VALIDATIONS
  private

  # Ensure issued_on is not set in the future
  def issued_on_cannot_be_in_the_future
    return if issued_on.blank?
    errors.add(:issued_on, "can't be in the future") if issued_on > Date.today
  end

  # Ensure that a certificate document is attached
  def document_must_be_attached
    errors.add(:document, "must be attached") unless document.attached?
  end
end

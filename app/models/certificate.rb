class Certificate < ApplicationRecord
  # ASSOCIATIONS
  belongs_to :employee
  belongs_to :course

  # Active Storage attachment for certificate documents
  has_one_attached :document

  # VALIDATIONS
  validates :name, presence: true
  validates :issued_on, presence: true
  validates :expiry_date,
            comparison: { greater_than: :issued_on, message: "must be after issued_on" },
            if: -> { expiry_date.present? }

  validate :issued_on_cannot_be_in_the_future
  validate :document_must_be_attached

  private

  # Ensure issued_on is not a future date
  def issued_on_cannot_be_in_the_future
    return if issued_on.blank?

    errors.add(:issued_on, "can't be in the future") if issued_on > Date.today
  end

  # Ensure a document is attached for the certificate
  def document_must_be_attached
    errors.add(:document, "must be attached") unless document.attached?
  end
end

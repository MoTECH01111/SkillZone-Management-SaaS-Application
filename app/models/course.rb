class Course < ApplicationRecord
  # Associations
  has_many :enrollments, dependent: :destroy
  has_many :certificates, dependent: :destroy

  # VALIDATIONS
  validates :title, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :capacity, numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end

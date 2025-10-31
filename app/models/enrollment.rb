class Enrollment < ApplicationRecord
  belongs_to :employee
  belongs_to :course

  # VALIDATIONS
  validates :status, presence: true, inclusion: { in: %w[active completed pending canceled] }
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validate :completed_on_cannot_be_before_course_start

  private

  # Ensure completed_on date is not before the course start_date
  def completed_on_cannot_be_before_course_start
    if completed_on.present? && course&.start_date.present? && completed_on < course.start_date
      errors.add(:completed_on, "can't be before the course start date")
    end
  end
end

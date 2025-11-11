class Enrollment < ApplicationRecord
  # ASSOCIATIONS
  belongs_to :employee
  belongs_to :course

  # VALIDATIONS
  validates :status, presence: true, inclusion: {
    in: %w[active completed pending canceled],
    message: "%{value} is not a valid status"
  }
  validates :progress,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true

  validates :employee_id, uniqueness: {
    scope: :course_id,
    message: "is already enrolled in this course"
  }

  validate :completed_on_cannot_be_before_course_start

  #  SCOPES 
  scope :active,     -> { where(status: "active") }
  scope :completed,  -> { where(status: "completed") }
  scope :pending,    -> { where(status: "pending") }
  scope :canceled,   -> { where(status: "canceled") }

  # CUSTOM VALIDATIONS
  private

  def completed_on_cannot_be_before_course_start
    return unless completed_on.present? && course&.start_date.present?
    if completed_on < course.start_date
      errors.add(:completed_on, "can't be before the course start date")
    end
  end
end

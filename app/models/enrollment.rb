class Enrollment < ApplicationRecord   # Enrollment model 
  #  Associations this is need for employee and course
  belongs_to :employee
  belongs_to :course

  # 4 Validations 
  validates :status, presence: true, inclusion: {
    in: %w[active completed pending canceled],
    message: "%{value} is not a valid status"
  }
  validates :progress,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true # Progress must be between 0-100

  validates :employee_id, uniqueness: {
    scope: :course_id,
    message: "is already enrolled in this course" # Employee can only be enrolled into the course once 
  }

  validate :completed_on_cannot_be_before_course_start

  # Scopes
  scope :active,     -> { where(status: "active") }
  scope :completed,  -> { where(status: "completed") }
  scope :pending,    -> { where(status: "pending") }
  scope :canceled,   -> { where(status: "canceled") }

  # Private helper 
  private

  def completed_on_cannot_be_before_course_start # Rule that completed on cannot be before the cours start date 
    return unless completed_on.present? && course&.start_date.present?
    if completed_on < course.start_date
      errors.add(:completed_on, "can't be before the course start date")
    end
  end
end

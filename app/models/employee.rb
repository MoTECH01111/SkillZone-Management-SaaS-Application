class Employee < ApplicationRecord
  # ASSOCIATIONS
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :certificates, dependent: :destroy
  before_save :set_admin_based_on_position


  # VALIDATIONS
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, format: { with: /\A[0-9+\-\s]+\z/, message: "only allows numbers, spaces, + or -" }
  validates :position, presence: true
  validates :department, presence: true
  validates :gender, inclusion: { in: %w[Male Female Other], message: "%{value} is not a valid gender" }
  validates :hire_date, presence: true, comparison: { less_than_or_equal_to: Date.today }

  # ADMIN VALIDATION
  validates :is_admin, inclusion: { in: [true, false], message: "must be true or false" }

  private

def set_admin_based_on_position
  # If position or role is "Manager" (case-insensitive), make the employee an admin
 if self.is_admin = position&.casecmp("manager")&.zero?
    self.is_admin = true
  else
    self.is_admin = false
  end
end

  # HELPER METHOD
  def admin?
    is_admin
  end
end

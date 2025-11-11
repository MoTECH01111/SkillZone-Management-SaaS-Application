class Employee < ApplicationRecord
  #  ASSOCIATIONS
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :certificates, dependent: :destroy

  #  CALLBACKS
  before_save :set_admin_based_on_position

  # VALIDATIONS
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true,
                    format: { with: /\A[0-9+\-\s]+\z/, message: "only allows numbers, spaces, + or -" }
  validates :position, presence: true
  validates :department, presence: true
  validates :gender, inclusion: { in: %w[Male Female Other], message: "%{value} is not a valid gender" }
  validates :hire_date, presence: true, comparison: { less_than_or_equal_to: Date.today }

  # METHODS 

  # Automatically sets admin privileges based on position
  def set_admin_based_on_position
    self.is_admin = position.to_s.downcase == "manager"
  end

  # Helper method for easy role checking
  def admin?
    is_admin
  end

  # Convenience method for displaying full name
  def full_name
    "#{first_name} #{last_name}"
  end
end

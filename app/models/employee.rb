class Employee < ApplicationRecord # Employee model, Handles relationships, validations and admin role control
  # Associations
  # Employye can enroll into any course 
  has_many :enrollments, dependent: :destroy # Deletes the related enrollment if employee is deleted
  has_many :courses, through: :enrollments # Course can be accessed through enrollments
  has_many :certificates, dependent: :destroy # Certifcates are deleted if employee is removed

  # Callbacks

  before_save :set_admin_based_on_position # Sets admin status before saving employee

  # 8 Validations 
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 } # First name must be entered and length between 2-50
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 } # Second name must be entered and length between 2-50

  validates :email, presence: true, uniqueness: true,    # Email must be entered a follow a standard email format
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :phone, presence: true,
                    format: { with: /\A[0-9+\-\s]+\z/, message: "only allows numbers, spaces, + or -" } # Phone number be entered

  validates :position, presence: true # Position must be entered
  validates :department, presence: true # Department must be entered

  validates :gender, inclusion: { # Gender must be entered and only available options
    in: %w[Male Female Other],
    message: "%{value} is not a valid gender"
  }

  validates :hire_date, presence: true,
                        comparison: { less_than_or_equal_to: Date.today } # Hire date must be entered and cannot be in the future

  # Admin Role logic
  def set_admin_based_on_position
    self.is_admin = position.to_s.downcase == "manager" # If an employee is a manager they are set as admins
  end

  # Helper to. check admin status 
  def admin? # Helper to. check admin status 
    is_admin
  end


  def full_name # Returns the employee full name 
    "#{first_name} #{last_name}"
  end

  # Used for my flask frontend  ensure admin atrribute is in API responses
  def as_json(options = {})
    super(options).merge({
      admin: self.is_admin
    })
  end
end

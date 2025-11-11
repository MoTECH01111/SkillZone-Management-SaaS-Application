class Course < ApplicationRecord
  # === Associations ===
  has_many :enrollments, dependent: :destroy
  has_many :employees, through: :enrollments
  has_many :certificates, dependent: :destroy

  # === Validations ===
  validates :title, presence: true, uniqueness: { case_sensitive: false }
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :capacity, numericality: { greater_than: 0 }
  validates :level, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate  :end_date_after_start_date

  # === Scopes (optional but useful) ===
  scope :upcoming, -> { where("start_date >= ?", Date.today) }
  scope :active,   -> { where("start_date <= ? AND end_date >= ?", Date.today, Date.today) }

  private

  # Custom validation
  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end

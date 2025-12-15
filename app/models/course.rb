class Course < ApplicationRecord # Course model
  # Associations
  has_many :enrollments, dependent: :destroy
  has_many :employees, through: :enrollments
  has_many :certificates, dependent: :destroy

  # 8 Validations
  validates :title, presence: true, uniqueness: { case_sensitive: false } # Title is not case sensitive
  validates :duration_minutes, numericality: { greater_than: 0 } # Duration is more than 0
  validates :capacity, numericality: { greater_than: 0 } # Capacity should be more than 0
  validates :level, presence: true
  validates :department, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate  :end_date_after_start_date

  # Scopes
  scope :upcoming, -> { where("start_date >= ?", Date.today) }
  scope :active,   -> { where("start_date <= ? AND end_date >= ?", Date.today, Date.today) }

  private

  # Custom validation
  def end_date_after_start_date # Sends error if end date is earlier than start date
    return if start_date.blank? || end_date.blank? # Skips validation if any of the dates is missing

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def embed_url # Function to except youtube link is inserted
    return nil unless youtube_url.present?
    video_id = youtube_url.split("v=").last.split("&").first
    "https://www.youtube.com/embed/#{video_id}"
  end
end

require "test_helper"

class CourseTest < ActiveSupport::TestCase
  fixtures :courses

  def setup
    @course = courses(:ruby_course)
  end

  # BASIC VALIDITY
  test "should be valid" do
    assert @course.valid?
  end

  # TITLE
  test "title must be present" do
    @course.title = ""
    assert_not @course.valid?, "Title can't be blank"
  end

  # DURATION
  test "duration_minutes must be present" do
    @course.duration_minutes = nil
    assert_not @course.valid?, "Duration can't be nil"
  end

  test "duration_minutes must be positive" do
    @course.duration_minutes = 0
    assert_not @course.valid?, "Duration must be greater than 0"
    @course.duration_minutes = -5
    assert_not @course.valid?, "Negative duration should be invalid"
  end

  # CAPACITY
  test "capacity must be present" do
    @course.capacity = nil
    assert_not @course.valid?, "Capacity can't be nil"
  end

  test "capacity must be positive" do
    @course.capacity = 0
    assert_not @course.valid?, "Capacity must be greater than 0"
    @course.capacity = -10
    assert_not @course.valid?, "Negative capacity should be invalid"
  end

  # DATES
  test "start_date must be present" do
    @course.start_date = nil
    assert_not @course.valid?, "Start date can't be blank"
  end

  test "end_date must be present" do
    @course.end_date = nil
    assert_not @course.valid?, "End date can't be blank"
  end

  test "end_date must be after start_date" do
    @course.start_date = Date.today
    @course.end_date = Date.yesterday
    assert_not @course.valid?, "End date cannot be before start date"

    @course.end_date = Date.today
    assert @course.valid?, "End date equal to start date should be valid"
  end
end


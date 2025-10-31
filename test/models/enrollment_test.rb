require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  fixtures :enrollments, :employees, :courses

  def setup
    @enrollment = enrollments(:enrollment_morris_ruby)
  end

  test "should be valid" do
    assert @enrollment.valid?
  end

  test "status must be allowed" do
    @enrollment.status = "invalid_status"
    assert_not @enrollment.valid?
  end

  test "progress must be between 0 and 100" do
    @enrollment.progress = 150
    assert_not @enrollment.valid?
  end

  test "enrollment must belong to employee and course" do
    assert_not_nil @enrollment.employee
    assert_not_nil @enrollment.course
  end
end

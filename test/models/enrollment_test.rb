require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase # Testing the Enrollment model
  fixtures :enrollments, :employees, :courses

  def setup # Setting up test using custom fixture
    @enrollment = enrollments(:enrollment_morris_ruby)
  end
  # Testing enrollment should be valid
  test "should be valid" do
    assert @enrollment.valid?
  end
  # Testing enrollment status
  test "status must be allowed" do
    @enrollment.status = "invalid_status"
    assert_not @enrollment.valid?
  end
  # Testing that the progress should be in between 0 and 100
  test "progress must be between 0 and 100" do
    @enrollment.progress = 150
    assert_not @enrollment.valid?
  end
  # Testing that enrollment belong to course and employee
  test "enrollment must belong to employee and course" do
    assert_not_nil @enrollment.employee
    assert_not_nil @enrollment.course
  end
end

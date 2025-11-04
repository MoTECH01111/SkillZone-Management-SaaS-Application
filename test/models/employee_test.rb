require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  fixtures :employees

  def setup
    @employee = employees(:morris)
  end

  test "should be valid" do
    assert @employee.valid?
  end

  # FIRST NAME
  test "first_name must be present" do
    @employee.first_name = ""
    assert_not @employee.valid?
  end

  test "first_name length should be within 2..50" do
    @employee.first_name = "A"
    assert_not @employee.valid?
    @employee.first_name = "A" * 51
    assert_not @employee.valid?
  end

  # LAST NAME
  test "last_name must be present" do
    @employee.last_name = ""
    assert_not @employee.valid?
  end

  test "last_name length should be within 2..50" do
    @employee.last_name = "B"
    assert_not @employee.valid?
    @employee.last_name = "B" * 51
    assert_not @employee.valid?
  end

  # EMAIL
  test "email must be present" do
    @employee.email = ""
    assert_not @employee.valid?
  end

  test "email should be unique" do
    duplicate = @employee.dup
    duplicate.email = @employee.email
    assert_not duplicate.valid?
  end

  # PHONE
  test "phone must be present" do
    @employee.phone = ""
    assert_not @employee.valid?
  end


  # POSITION
  test "position must be present" do
    @employee.position = ""
    assert_not @employee.valid?
  end

  # DEPARTMENT
  test "department must be present" do
    @employee.department = ""
    assert_not @employee.valid?
  end

  # GENDER
  test "gender must be valid" do
    @employee.gender = "Unknown"
    assert_not @employee.valid?
    [ "Male", "Female", "Other" ].each do |g|
      @employee.gender = g
      assert @employee.valid?, "#{g} should be valid"
    end
  end

  # HIRE DATE
  test "hire_date should not be in the future" do
    @employee.hire_date = Date.tomorrow
    assert_not @employee.valid?
  end
end

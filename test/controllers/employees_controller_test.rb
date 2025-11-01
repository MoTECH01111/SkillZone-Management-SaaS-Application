require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = employees(:manager)       # admin fixture
    @non_admin = employees(:developer) # non-admin fixture
    @employee = employees(:john)       # employee fixture
  end

  # Helper to stub current_employee
  def login_as(employee)
    EmployeesController.any_instance.stubs(:current_employee).returns(employee)
  end

  # INDEX
  test "should get index as admin" do
    login_as(@admin)
    get employees_url
    assert_response :success
  end

  test "should get index as non-admin" do
    login_as(@non_admin)
    get employees_url
    assert_response :success
  end

  # SHOW
  test "should show employee as admin" do
    login_as(@admin)
    get employee_url(@employee)
    assert_response :success
  end

  test "should show employee as non-admin" do
    login_as(@non_admin)
    get employee_url(@employee)
    assert_response :success
  end

  # CREATE
  test "should create employee as admin" do
    login_as(@admin)
    assert_difference("Employee.count", 1) do
      post employees_url, params: { employee: { 
        first_name: "Test", last_name: "User", email: "testuser@example.com", 
        phone: "1234567890", position: "Developer", department: "IT", 
        gender: "Male", hire_date: Date.today 
      } }
    end
    assert_redirected_to employee_path(Employee.last)
  end

  # UPDATE
  test "should update employee as admin" do
    login_as(@admin)
    patch employee_url(@employee), params: { employee: { first_name: "Updated" } }
    assert_redirected_to employee_path(@employee)
    @employee.reload
    assert_equal "Updated", @employee.first_name
  end

  test "should not update employee as non-admin" do
    login_as(@non_admin)
    patch employee_url(@employee), params: { employee: { first_name: "FailUpdate" } }
    assert_redirected_to employees_url
    @employee.reload
    assert_not_equal "FailUpdate", @employee.first_name
  end

  # DESTROY
  test "should destroy employee as admin" do
    login_as(@admin)
    assert_difference("Employee.count", -1) do
      delete employee_url(@employee)
    end
    assert_redirected_to employees_url
  end
end

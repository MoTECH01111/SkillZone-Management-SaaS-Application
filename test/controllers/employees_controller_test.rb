require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = employees(:manager)        # admin fixture
    @non_admin = employees(:developer)  # non-admin fixture
    @employee = employees(:john)        # employee fixture
  end

  # Helper to stub current_employee
  def login_as(employee)
    EmployeesController.any_instance.stubs(:current_employee).returns(employee)
  end

  # INDEX
  test "should get index as admin" do
    login_as(@admin)
    get employees_url, as: :json
    assert_response :success
    assert_includes @response.content_type, "application/json"
  end

  test "should get index as non-admin" do
    login_as(@non_admin)
    get employees_url, as: :json
    assert_response :success
    assert_includes @response.content_type, "application/json"
  end

  # SHOW
  test "should show employee as admin" do
    login_as(@admin)
    get employee_url(@employee), as: :json
    assert_response :success
    assert_includes @response.content_type, "application/json"
  end

  test "should show employee as non-admin" do
    login_as(@non_admin)
    get employee_url(@employee), as: :json
    assert_response :success
    assert_includes @response.content_type, "application/json"
  end

  # CREATE
  test "should create employee as admin" do
    login_as(@admin)
    assert_difference("Employee.count", 1) do
      post employees_url, params: { employee: { 
        first_name: "Test", last_name: "User", email: "testuser@example.com", 
        phone: "1234567890", position: "Developer", department: "IT", 
        gender: "Male", hire_date: Date.today 
      } }, as: :json
    end
    assert_response :created
    json = JSON.parse(@response.body)
    assert_equal "Test", json["first_name"]
  end

  test "should not create employee as non-admin" do
    login_as(@non_admin)
    assert_no_difference("Employee.count") do
      post employees_url, params: { employee: { first_name: "Fail" } }, as: :json
    end
    assert_response :forbidden
    json = JSON.parse(@response.body)
    assert_equal "Access denied. Admins only.", json["error"]
  end

  # UPDATE
  test "should update employee as admin" do
    login_as(@admin)
    patch employee_url(@employee), params: { employee: { first_name: "Updated" } }, as: :json
    assert_response :ok
    json = JSON.parse(@response.body)
    assert_equal "Updated", json["first_name"]
    @employee.reload
    assert_equal "Updated", @employee.first_name
  end

  test "should not update employee as non-admin" do
    login_as(@non_admin)
    patch employee_url(@employee), params: { employee: { first_name: "FailUpdate" } }, as: :json
    assert_response :forbidden
    @employee.reload
    assert_not_equal "FailUpdate", @employee.first_name
  end

  # DESTROY
  test "should destroy employee as admin" do
    login_as(@admin)
    assert_difference("Employee.count", -1) do
      delete employee_url(@employee), as: :json
    end
    assert_response :no_content
  end

  test "should not destroy employee as non-admin" do
    login_as(@non_admin)
    assert_no_difference("Employee.count") do
      delete employee_url(@employee), as: :json
    end
    assert_response :forbidden
  end
end

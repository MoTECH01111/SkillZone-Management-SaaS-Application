require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest # Testing for the employee controller 
  setup do # test data using fixtures
    @admin = employees(:manager)
    @non_admin = employees(:developer)
    @employee = employees(:john)
    @another_employee = employees(:alice)
  end

  # Helper - adds ?employee_id=<id> to the request
  def auth_query(user)
    { employee_id: user.id }
  end

  # Testing for INDEX functions
  test "should get index as admin" do # Admin can view all employees
    get employees_url(auth_query(@admin)), as: :json
    assert_response :success
  end

  test "should NOT get index as non-admin" do # non - Admin cannot view all employees
    get employees_url(auth_query(@non_admin)), as: :json
 
    assert_response :forbidden # Expect forbidden acces
    json = JSON.parse(@response.body) 
    assert_equal "Admins only", json["error"]
  end

  # Testing for SHOW functions
  test "should show employee" do
    get employee_url(@employee, auth_query(@employee)), as: :json

    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal @employee.id, json["id"]
  end

  # Testing for CREATE functions
  test "should create employee" do
    assert_difference("Employee.count", 1) do
      post employees_url(auth_query(@admin)),
        params: {
          employee: {
            first_name:  "Test",
            last_name:   "User",
            email:       "test_user@example.com",
            phone:       "123456789",
            position:    "Engineer",
            department:  "IT",
            gender:      "Male",
            hire_date:   "2024-01-01",
          }
        },
        as: :json
    end

    assert_response :created
  end

  # Testing for UPDATE Functions
  test "should update employee as admin" do
    patch employee_url(@employee, auth_query(@admin)),
      params: { employee: { first_name: "AdminEdit" } },
      as: :json

    assert_response :success
    @employee.reload
    assert_equal "AdminEdit", @employee.first_name
  end

  test "should update own profile as non-admin" do
    patch employee_url(@non_admin, auth_query(@non_admin)),
      params: { employee: { first_name: "MyEdit" } },
      as: :json

    assert_response :success
    @non_admin.reload
    assert_equal "MyEdit", @non_admin.first_name
  end

  test "should NOT update another employee as non-admin" do
    patch employee_url(@employee, auth_query(@non_admin)),
      params: { employee: { first_name: "HACKED" } },
      as: :json

    assert_response :forbidden
    json = JSON.parse(@response.body)
    assert_equal "Access denied", json["error"]
  end
  
  # Testing for DESTROY functions
  test "should destroy employee as admin" do
    assert_difference("Employee.count", -1) do
      delete employee_url(@another_employee, auth_query(@admin)), as: :json
    end
    assert_response :no_content
  end

  test "should NOT destroy employee as non-admin" do
    assert_no_difference("Employee.count") do
      delete employee_url(@employee, auth_query(@non_admin)), as: :json
    end

    assert_response :forbidden
    json = JSON.parse(@response.body)
    assert_equal "Admins only", json["error"]
  end
end

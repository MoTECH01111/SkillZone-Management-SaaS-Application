require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = employees(:manager)
    @non_admin = employees(:developer)
    @employee = employees(:john)
    @course = courses(:sample_course)
    @enrollment = enrollments(:active_enrollment)
  end

  # Helper to simulate logged-in employee
  def login_as(employee)
    EnrollmentsController.any_instance.stubs(:current_employee).returns(employee)
  end

  # INDEX
  test "should get index" do
    login_as(@admin)
    get enrollments_url, as: :json
    assert_response :success
    json = JSON.parse(@response.body)
    assert_kind_of Array, json
    assert_includes json.first.keys, "status"
  end

  # SHOW
  test "should show enrollment" do
    login_as(@admin)
    get enrollment_url(@enrollment), as: :json
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal @enrollment.id, json["id"]
  end

  # CREATE
  test "should create enrollment as admin with valid params" do
    login_as(@admin)
    assert_difference("Enrollment.count", 1) do
      post enrollments_url, params: {
        enrollment: {
          employee_id: @employee.id,
          course_id: @course.id,
          status: "active",
          progress: 50
        }
      }, as: :json
    end
    assert_response :created
    json = JSON.parse(@response.body)
    assert_equal "active", json["status"]
  end

  test "should not create enrollment with invalid progress" do
    login_as(@admin)
    assert_no_difference("Enrollment.count") do
      post enrollments_url, params: {
        enrollment: {
          employee_id: @employee.id,
          course_id: @course.id,
          status: "active",
          progress: 200
        }
      }, as: :json
    end
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"].join, "must be less than or equal to 100"
  end

  test "non-admin should not create enrollment" do
    login_as(@non_admin)
    assert_no_difference("Enrollment.count") do
      post enrollments_url, params: {
        enrollment: {
          employee_id: @employee.id,
          course_id: @course.id,
          status: "active",
          progress: 50
        }
      }, as: :json
    end
    assert_response :forbidden
  end

  # UPDATE
  test "should update enrollment as admin" do
    login_as(@admin)
    patch enrollment_url(@enrollment), params: {
      enrollment: { status: "completed", progress: 100 }
    }, as: :json
    assert_response :success
    @enrollment.reload
    assert_equal "completed", @enrollment.status
  end

  test "should not update enrollment with invalid progress" do
    login_as(@admin)
    patch enrollment_url(@enrollment), params: {
      enrollment: { progress: -10 }
    }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"].join, "must be greater than or equal to 0"
  end

  test "non-admin should not update enrollment" do
    login_as(@non_admin)
    patch enrollment_url(@enrollment), params: {
      enrollment: { status: "completed" }
    }, as: :json
    assert_response :forbidden
  end

  # DESTROY
  test "should destroy enrollment as admin" do
    login_as(@admin)
    assert_difference("Enrollment.count", -1) do
      delete enrollment_url(@enrollment), as: :json
    end
    assert_response :no_content
  end

  test "non-admin should not destroy enrollment" do
    login_as(@non_admin)
    assert_no_difference("Enrollment.count") do
      delete enrollment_url(@enrollment), as: :json
    end
    assert_response :forbidden
  end
end

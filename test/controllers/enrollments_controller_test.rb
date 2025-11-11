require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = employees(:manager)
    @non_admin = employees(:developer)
    @employee = employees(:john)
    @sample_course = courses(:sample_course)
    @new_course = courses(:new_course) # fresh course for enrollment creation tests
    @enrollment = enrollments(:active_enrollment)
  end

  # Helper to simulate logged-in employee
  def login_as(employee)
    EnrollmentsController.any_instance.stubs(:current_employee).returns(employee)
  end

  # ======================
  # INDEX
  # ======================
  test "admin should see all enrollments" do
    login_as(@admin)
    get course_enrollments_url(@sample_course), as: :json
    assert_response :success

    json = JSON.parse(@response.body)
    assert_kind_of Array, json
    assert_includes json.first.keys, "status"
    assert_includes json.first.keys, "employee"
    assert_includes json.first.keys, "course"
  end

  test "employee should see only their own enrollments" do
    login_as(@employee)
    get course_enrollments_url(@sample_course), as: :json
    assert_response :success

    json = JSON.parse(@response.body)
    assert json.all? { |e| e["employee"]["id"] == @employee.id }
  end

  # ======================
  # SHOW
  # ======================
  test "employee can view their own enrollment" do
    login_as(@employee)
    get enrollment_url(@enrollment), as: :json
    if @enrollment.employee_id == @employee.id
      assert_response :success
    else
      assert_response :forbidden
    end
  end

  test "admin can view any enrollment" do
    login_as(@admin)
    get enrollment_url(@enrollment), as: :json
    assert_response :success
  end

  # ======================
  # CREATE
  # ======================
  test "employee can create enrollment for self" do
    login_as(@employee)
    assert_difference("Enrollment.count", 1) do
      post course_enrollments_url(@new_course), params: {
        enrollment: { employee_id: @employee.id, course_id: @new_course.id, status: "active", progress: 0 }
      }, as: :json
    end
    assert_response :created
  end

  test "employee cannot create enrollment for another employee" do
    login_as(@non_admin)
    assert_no_difference("Enrollment.count") do
      post course_enrollments_url(@new_course), params: {
        enrollment: { employee_id: @employee.id, course_id: @new_course.id, status: "active", progress: 0 }
      }, as: :json
    end
    assert_response :forbidden
    json = JSON.parse(@response.body)
    assert_equal "You can only enroll yourself.", json["error"]
  end

  test "admin can create enrollment for any employee" do
    login_as(@admin)
    assert_difference("Enrollment.count", 1) do
      post course_enrollments_url(@new_course), params: {
        enrollment: { employee_id: @employee.id, course_id: @new_course.id, status: "active", progress: 0 }
      }, as: :json
    end
    assert_response :created
  end

  # ======================
  # UPDATE
  # ======================
  test "employee can update their own enrollment" do
    login_as(@employee)
    patch enrollment_url(@enrollment), params: {
      enrollment: { status: "completed", progress: 100 }
    }, as: :json

    if @enrollment.employee_id == @employee.id
      assert_response :success
      @enrollment.reload
      assert_equal "completed", @enrollment.status
      assert_equal 100, @enrollment.progress
    else
      assert_response :forbidden
    end
  end

  test "employee cannot update another employee's enrollment" do
    login_as(@non_admin)
    patch enrollment_url(@enrollment), params: {
      enrollment: { status: "completed", progress: 100 }
    }, as: :json
    assert_response :forbidden
  end

  test "admin can update any enrollment" do
    login_as(@admin)
    patch enrollment_url(@enrollment), params: {
      enrollment: { status: "completed", progress: 100 }
    }, as: :json
    assert_response :success
    @enrollment.reload
    assert_equal "completed", @enrollment.status
    assert_equal 100, @enrollment.progress
  end

  # ======================
  # DESTROY
  # ======================
  test "admin can destroy enrollment" do
    login_as(@admin)
    assert_difference("Enrollment.count", -1) do
      delete enrollment_url(@enrollment), as: :json
    end
    assert_response :no_content
  end

  test "employee cannot destroy enrollment" do
    login_as(@non_admin)
    assert_no_difference("Enrollment.count") do
      delete enrollment_url(@enrollment), as: :json
    end
    assert_response :forbidden
    json = JSON.parse(@response.body)
    assert_equal "Only admins can delete enrollments.", json["error"]
  end
end

require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest # Test for Enrollment Controller
  setup do # Fixtures used to set up test data
    @admin = employees(:manager)
    @non_admin = employees(:developer)
    @employee = employees(:john)

    @sample_course = courses(:sample_course)
    @new_course = courses(:new_course)

    @enrollment = enrollments(:active_enrollment)
  end

  # Helper for login
  def login_as(employee)
    EnrollmentsController.any_instance.stubs(:current_employee).returns(employee)
  end

  # INDEX Testing that all enrollments can be accessed
  test "index should list all enrollments" do
    get enrollments_url, as: :json
    assert_response :success

    json = JSON.parse(@response.body)
    assert_kind_of Array, json
    assert json.length >= 1
    assert_includes json.first.keys, "status"
    assert_includes json.first.keys, "employee"
    assert_includes json.first.keys, "course"
  end


  # SHOW Testing that enrollments are displayed
  test "show should return enrollment" do
    get enrollment_url(@enrollment), as: :json
    assert_response :success

    json = JSON.parse(@response.body)
    assert_equal @enrollment.id, json["id"]
  end


  # CREATE Testing that enrollemnts can be created
  test "should create enrollment" do
    assert_difference("Enrollment.count", 1) do
      post enrollments_url, params: {
        enrollment: {
          employee_id: @employee.id,
          course_id: @new_course.id,
          status: "active",
          progress: 0
        }
      }, as: :json
    end

    assert_response :created
  end


  # UPDATE Tesing that enrollmnnts can be updated
  test "should update enrollment" do
    patch enrollment_url(@enrollment), params: {
      enrollment: { status: "completed", progress: 100 }
    }, as: :json

    assert_response :success
    @enrollment.reload
    assert_equal "completed", @enrollment.status
    assert_equal 100, @enrollment.progress
  end


  # DESTROY Testing that enrollments can be deleted
  test "should destroy enrollment" do
    assert_difference("Enrollment.count", -1) do
      delete enrollment_url(@enrollment), as: :json
    end

    assert_response :no_content
  end
end

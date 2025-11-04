require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:sample_course)
    @admin  = employees(:manager)
    @user   = employees(:john)
  end

  # INDEX
  test "should get index" do
    get courses_url, as: :json
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal Course.count, json.size
  end

  # SHOW
  test "should show course" do
    get course_url(@course), as: :json
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal @course.title, json["title"]
  end

  # CREATE
  test "admin should create course" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)
    assert_difference("Course.count", 1) do
      post courses_url, params: {
        course: {
          title: "New Course",
          duration_minutes: 90,
          capacity: 20,
          level: "Intermediate",
          start_date: Date.today,
          end_date: Date.today + 7.days
        }
      }, as: :json
    end
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "New Course", json["title"]
  end

  test "should not create course if invalid" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)
    assert_no_difference("Course.count") do
      post courses_url, params: { course: { title: "" } }, as: :json
    end
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"], "Title can't be blank"
  end

  # UPDATE
  test "admin should update course" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)
    patch course_url(@course), params: { course: { title: "Updated Title" } }, as: :json
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Updated Title", json["title"]
    @course.reload
    assert_equal "Updated Title", @course.title
  end

  # DESTROY
  test "admin should destroy course" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)
    assert_difference("Course.count", -1) do
      delete course_url(@course), as: :json
    end
    assert_response :no_content
  end

  # NON-ADMIN ACCESS
  test "non-admin should be forbidden" do
    CoursesController.any_instance.stubs(:current_employee).returns(@user)
    
    # Create attempt
    post courses_url, params: { course: { title: "Test" } }, as: :json
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal "Access denied. Admins only.", json["error"]

    # Update attempt
    patch course_url(@course), params: { course: { title: "Test" } }, as: :json
    assert_response :forbidden

    # Destroy attempt
    delete course_url(@course), as: :json
    assert_response :forbidden
  end
end

require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:sample_course)   # existing course fixture
    @admin  = employees(:manager)       # is_admin: true
    @user   = employees(:john)          # is_admin: false
  end

  # ======================
  # INDEX
  # ======================
  test "should get index" do
    get courses_url, as: :json
    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal Course.count, json.size
  end

  # ======================
  # SHOW
  # ======================
  test "should show course" do
    get course_url(@course), as: :json
    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal @course.title, json["title"]
  end

  # ======================
  # CREATE (ADMIN ONLY)
  # ======================
  test "admin should create course" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)

    assert_difference("Course.count", 1) do
      post courses_url, params: {
        course: {
          title: "New Leadership Course",
          duration_minutes: 120,
          capacity: 25,
          level: "Intermediate",
          start_date: Date.today,
          end_date: Date.today + 5.days
        }
      }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "New Leadership Course", json["title"]
  end

  # ======================
  # CREATE (INVALID DATA)
  # ======================
  test "should not create course with invalid data" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)

    assert_no_difference("Course.count") do
      post courses_url, params: { course: { title: "" } }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"], "Title can't be blank"
  end

  # ======================
  # UPDATE (ADMIN ONLY)
  # ======================
  test "admin should update course" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)

    patch course_url(@course), params: { course: { title: "Updated Course Title" } }, as: :json
    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal "Updated Course Title", json["title"]

    @course.reload
    assert_equal "Updated Course Title", @course.title
  end

  # ======================
  # DESTROY (ADMIN ONLY)
  # ======================
  test "admin should destroy course" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)

    assert_difference("Course.count", -1) do
      delete course_url(@course), as: :json
    end

    assert_response :no_content
  end

  # ======================
  # NON-ADMIN ACCESS BLOCKED
  # ======================
  test "non-admin should not be allowed to create, update, or delete" do
    CoursesController.any_instance.stubs(:current_employee).returns(@user)

    # Attempt to create
    post courses_url, params: {
      course: {
        title: "Unauthorized Course",
        duration_minutes: 60,
        capacity: 10,
        start_date: Date.today,
        end_date: Date.today + 3.days
      }
    }, as: :json
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal "Access denied. Admins only.", json["error"]

    # Attempt to update
    patch course_url(@course), params: { course: { title: "Hack Attempt" } }, as: :json
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal "Access denied. Admins only.", json["error"]

    # Attempt to delete
    delete course_url(@course), as: :json
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal "Access denied. Admins only.", json["error"]
  end
end

require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest # Testing Course Controller 
  setup do # Setup test data with fictures
    @course = courses(:sample_course)   # existing course fixture
    @admin  = employees(:manager)       # is_admin: true
    @user   = employees(:john)          # is_admin: false
  end
 
  # Testing access to all courses
  test "should get index" do
    get courses_url, as: :json
    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal Course.count, json.size
  end

  # Test to show all course
  test "should show course" do
    get course_url(@course), as: :json
    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal @course.title, json["title"]
  end

  # Testing only admins can create courses
  test "admin should create course" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)

    assert_difference("Course.count", 1) do
      post courses_url, params: {
        course: {
          title: "New Leadership Course",
          description: "Learn leadership skills",
          duration_minutes: 120,
          department: "HR",
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

  # Testing that course should not create with invalid data 
  test "should not create course with invalid data" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)

    assert_no_difference("Course.count") do
      post courses_url, params: { course: { title: "" } }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"], "Title can't be blank"
  end

  # Testing that only admins can update courses
  test "admin should update course" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)

    patch course_url(@course), params: {
      course: {
        title: "Updated Course Title",
        department: @course.department,  # required
        description: @course.description,
        duration_minutes: @course.duration_minutes,
        capacity: @course.capacity,
        level: @course.level,
        start_date: @course.start_date,
        end_date: @course.end_date
      }
    }, as: :json

    assert_response :ok

    json = JSON.parse(response.body)
    assert_equal "Updated Course Title", json["title"]

    @course.reload
    assert_equal "Updated Course Title", @course.title
  end

  # Testing only admins can delete courses
  test "admin should destroy course" do
    CoursesController.any_instance.stubs(:current_employee).returns(@admin)

    assert_difference("Course.count", -1) do
      delete course_url(@course), as: :json
    end

    assert_response :no_content
  end

  # Testing non admin functionalities 
  test "non-admin should not be allowed to create, update, or delete" do
    CoursesController.any_instance.stubs(:current_employee).returns(@user)

    # Testing to  Attempt to create
    post courses_url, params: {
      course: {
        title: "Internet of things",
        description: "Basic IoT course",
        duration_minutes: 60,
        department: "IT",
        capacity: 10,
        level: "Beginner",
        start_date: Date.today,
        end_date: Date.today + 3.days
      }
    }, as: :json
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal "Admins only", json["error"]

    # Testing to Attempt to update
    patch course_url(@course), params: { course: { title: "Hack Attempt" } }, as: :json
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal "Admins only", json["error"]

    # Testing to Attempt to delete
    delete course_url(@course), as: :json
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal "Admins only", json["error"]
  end
end

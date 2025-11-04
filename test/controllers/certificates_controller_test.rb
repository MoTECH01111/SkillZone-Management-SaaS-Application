require "test_helper"
include ActionDispatch::TestProcess::FixtureFile

class CertificatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = employees(:manager)       # Admin user fixture
    @non_admin = employees(:developer) # Non-admin fixture
    @employee = employees(:john)       # Employee fixture
    @course = courses(:sample_course)  # Course fixture
    @certificate = certificates(:ruby_certificate) # Certificate fixture
  end

  # Helper to stub current_employee
  def login_as(employee)
    CertificatesController.any_instance.stubs(:current_employee).returns(employee)
  end

  # INDEX
  test "should get index" do
    login_as(@admin)
    get certificates_url, as: :json
    assert_response :success
    assert_includes @response.body, @certificate.name
  end

  # SHOW
  test "should show certificate" do
    login_as(@admin)
    get certificate_url(@certificate), as: :json
    assert_response :success
    assert_includes @response.body, @certificate.name
  end

  # CREATE
  test "should create certificate as admin with valid params" do
    login_as(@admin)
    assert_difference("Certificate.count", 1) do
      post certificates_url, params: {
        certificate: {
          name: "New Certificate",
          issued_on: Date.today - 1.week,
          expiry_date: Date.today + 1.year,
          employee_id: @employee.id,
          course_id: @course.id,
          document: fixture_file_upload(Rails.root.join("test/fixtures/files/sample.pdf"), "application/pdf")
        }
      }, as: :multipart
    end
    assert_response :created
    json = JSON.parse(@response.body)
    assert_equal "New Certificate", json["name"]
  end

  test "should not create certificate with invalid params" do
    login_as(@admin)
    assert_no_difference("Certificate.count") do
      post certificates_url, params: { certificate: { name: "", employee_id: nil, course_id: nil } }, as: :multipart
    end
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"].join, "can't be blank"
  end

  # UPDATE
  test "should update certificate as admin with valid params" do
    login_as(@admin)
    patch certificate_url(@certificate), params: {
      certificate: {
        name: "Updated Certificate",
        document: fixture_file_upload(Rails.root.join("test/fixtures/files/sample.pdf"), "application/pdf")
      }
    }, as: :multipart
    assert_response :success
    @certificate.reload
    assert_equal "Updated Certificate", @certificate.name
  end

  test "should not update certificate with invalid params" do
    login_as(@admin)
    patch certificate_url(@certificate), params: {
      certificate: { name: "" }
    }, as: :multipart
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"].join, "can't be blank"
  end

  # DESTROY
  test "should destroy certificate as admin" do
    login_as(@admin)
    assert_difference("Certificate.count", -1) do
      delete certificate_url(@certificate), as: :json
    end
    assert_response :no_content
  end

  # NON-ADMIN access
  test "non-admin should not create certificate" do
    login_as(@non_admin)
    post certificates_url, params: { certificate: { name: "Test" } }, as: :multipart
    assert_response :forbidden
  end

  test "non-admin should not update certificate" do
    login_as(@non_admin)
    patch certificate_url(@certificate), params: { certificate: { name: "Fail" } }, as: :multipart
    assert_response :forbidden
  end

  test "non-admin should not destroy certificate" do
    login_as(@non_admin)
    delete certificate_url(@certificate), as: :json
    assert_response :forbidden
  end
end

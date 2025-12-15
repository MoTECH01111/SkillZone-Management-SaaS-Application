require "test_helper"
include ActionDispatch::TestProcess::FixtureFile

class CertificatesControllerTest < ActionDispatch::IntegrationTest # Testing the Certificate controller
  setup do
    @admin = employees(:manager)       # Admin user fixture
    @non_admin = employees(:developer) # Non-admin fixture
    @employee = employees(:john)       # Employee fixture
    @course = courses(:sample_course)  # Course fixture
    @certificate = certificates(:ruby_certificate) # Certificate fixture
  end

  # Helper forcurrent_employee
  def login_as(employee)
    CertificatesController.any_instance.stubs(:current_employee).returns(employee)
  end

  # Testing the INDEX to ensure admin can return all certificates
  test "should get index" do
    login_as(@admin)
    get certificates_url, as: :json
    assert_response :success
    assert_includes @response.body, @certificate.name
  end

  # Testing the SHOW to ensure admin can return all certificates
  test "should show certificate" do
    login_as(@admin)
    get certificate_url(@certificate), as: :json
    assert_response :success
    assert_includes @response.body, @certificate.name
  end

  # Testing the CREATE to ensure admin can can certificates
  test "should create certificate as admin with valid params" do
    login_as(@admin)

    assert_difference("Certificate.count", 1) do
      post certificates_url, params: {
        certificate: {
          name: "New Certificate",
          description: "Issued for course completion",
          issued_on: Date.today - 1.week,
          expiry_date: Date.today + 1.year,
          employee_id: @employee.id,
          course_id: @course.id,
          document: fixture_file_upload(
            Rails.root.join("test/fixtures/files/sample.pdf"),
            "application/pdf"
          )
        }
      }, as: :multipart
    end

    assert_response :created
  end

  # Testing to ensure all valid params are accepted
  test "should not create certificate with invalid params" do
    login_as(@admin)
    assert_no_difference("Certificate.count") do
      post certificates_url, params: { certificate: { name: "", employee_id: nil, course_id: nil } }, as: :multipart
    end
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"].join, "can't be blank"
  end

  # Testing the UPDATE with valid param
  test "should update certificate as admin with valid params" do
    login_as(@admin)

    patch certificate_url(@certificate), params: {
      certificate: {
        name: "Updated Certificate",
        description: "Updated description",
        issued_on: @certificate.issued_on,
        expiry_date: @certificate.expiry_date,
        employee_id: @certificate.employee_id,
        course_id: @certificate.course_id,
        document: fixture_file_upload(
          Rails.root.join("test/fixtures/files/sample.pdf"),
          "application/pdf"
        )
      }
    }, as: :multipart

    assert_response :success
    @certificate.reload
    assert_equal "Updated Certificate", @certificate.name
  end

  # Testing to ensure certificates are not updated with invalid parameters
  test "should not update certificate with invalid params" do
    login_as(@admin)
    patch certificate_url(@certificate), params: {
      certificate: { name: "" }
    }, as: :multipart
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"].join, "can't be blank"
  end

  # Testing the DESTROY to ensure admins can delete certificates
  test "should destroy certificate as admin" do
    login_as(@admin)
    assert_difference("Certificate.count", -1) do
      delete certificate_url(@certificate), as: :json
    end
    assert_response :no_content
  end

  # Testing NON ADMIN cannot create certicates
  test "non-admin should not create certificate" do
    login_as(@non_admin)
    post certificates_url, params: { certificate: { name: "Test" } }, as: :multipart
    assert_response :forbidden
  end

  # Testing NON ADMIN cannot update certicates
  test "non-admin should not update certificate" do
    login_as(@non_admin)
    patch certificate_url(@certificate), params: { certificate: { name: "Fail" } }, as: :multipart
    assert_response :forbidden
  end
  # Testing NON ADMIN cannot delete certicates
  test "non-admin should not destroy certificate" do
    login_as(@non_admin)
    delete certificate_url(@certificate), as: :json
    assert_response :forbidden
  end
  # Testing NON ADMIN can access all certificates
  test "non-admin should get index" do
    login_as(@non_admin)
    get certificates_url, as: :json
    assert_response :success
    assert_includes @response.body, @certificate.name
  end

  # Testing NON ADMIN can diaplay their certificates
  test "non-admin should show certificate" do
    login_as(@non_admin)
    get certificate_url(@certificate), as: :json
    assert_response :success
    assert_includes @response.body, @certificate.name
  end
end

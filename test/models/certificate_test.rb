require "test_helper"

class CertificateTest < ActiveSupport::TestCase
  fixtures :certificates, :employees, :courses

 def setup
  @certificate = certificates(:certificate_morris_ruby)

  puts "DEBUG: #{@certificate.attributes.inspect}"

  @certificate.document.attach(
    io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")),
    filename: "sample.pdf",
    content_type: "application/pdf"
  ) unless @certificate.document.attached?
end

  test "should be valid" do
    assert @certificate.valid?, "Certificate should be valid"
  end

  test "issued_on should not be in the future" do
    @certificate.issued_on = Date.tomorrow
    assert_not @certificate.valid?, "issued_on in the future should be invalid"
  end

  test "expiry_date should be after issued_on" do
    @certificate.expiry_date = @certificate.issued_on - 1
    assert_not @certificate.valid?, "expiry_date before issued_on should be invalid"
  end

  test "document should be attached" do
    assert @certificate.document.attached?, "Certificate should have a document attached"
  end
end

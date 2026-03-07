# test/controllers/checkins_controller_test.rb
require "test_helper"

class CheckinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @course = courses(:one)
    @checkin_form = checkin_forms(:one)

    EnrolledStudent.find_or_create_by!(course: @course, student_id: @student.student_id)
    @checkin_form.update!(active: true)
  end

  # ===== Authentication =====

  test "should redirect to login if not authenticated" do
    get checkin_path(@checkin_form.qr_token)
    assert_redirected_to new_user_session_path
  end

  test "should redirect if user is teacher" do
    sign_in @teacher
    get checkin_path(@checkin_form.qr_token)
    assert_redirected_to root_path
  end

  # ===== New Action =====

  test "should get new for enrolled student" do
    sign_in @student
    get checkin_path(@checkin_form.qr_token)
    assert_response :success
  end

  test "should render expired if token not found" do
    sign_in @student
    get checkin_path("invalid_token")
    assert_response :success
    assert_match /หมดอายุ|expired/i, response.body
  end

  test "should render closed if form is not active" do
    sign_in @student
    @checkin_form.update!(active: false)
    get checkin_path(@checkin_form.qr_token)
    assert_response :success
    assert_match /ปิด|closed/i, response.body
  end

  test "should render not_enrolled if student not in course" do
    sign_in @student
    EnrolledStudent.where(course: @course, student_id: @student.student_id).destroy_all
    get checkin_path(@checkin_form.qr_token)
    assert_response :success
    assert_match /ไม่ได้ลงทะเบียน|not enrolled/i, response.body
  end

  test "should render success if already checked in" do
    sign_in @student
    Attendance.create!(
      checkin_form: @checkin_form,
      student_id: @student.student_id,
      name: @student.name,
      photo: { io: StringIO.new("fake"), filename: "test.jpg", content_type: "image/jpeg" }
    )
    get checkin_path(@checkin_form.qr_token)
    assert_response :success
    assert_match /สำเร็จ|success/i, response.body
  end

  # ===== Create Action =====

  test "should create attendance for online mode" do
    sign_in @student
    @checkin_form.update!(mode: :online)

    assert_difference("Attendance.count") do
      post checkin_path(@checkin_form.qr_token), params: {
        checkin_form_id: @checkin_form.id,
        photo: fixture_file_upload("test_photo.jpg", "image/jpeg")
      }
    end
    assert_redirected_to checkin_path(@checkin_form.qr_token)
  end

  test "should create attendance for onsite mode within radius" do
    sign_in @student
    @checkin_form.update!(
      mode: :onsite,
      latitude: 13.7563,
      longitude: 100.5018,
      radius: 100
    )

    assert_difference("Attendance.count") do
      post checkin_path(@checkin_form.qr_token), params: {
        checkin_form_id: @checkin_form.id,
        latitude: 13.7563,
        longitude: 100.5018,
        photo: fixture_file_upload("test_photo.jpg", "image/jpeg")
      }
    end
    assert_redirected_to checkin_path(@checkin_form.qr_token)
  end

  test "should not create attendance for onsite mode outside radius" do
    sign_in @student
    @checkin_form.update!(
      mode: :onsite,
      latitude: 13.7563,
      longitude: 100.5018,
      radius: 100
    )

    assert_no_difference("Attendance.count") do
      post checkin_path(@checkin_form.qr_token), params: {
        checkin_form_id: @checkin_form.id,
        latitude: 14.0,
        longitude: 101.0,
        photo: fixture_file_upload("test_photo.jpg", "image/jpeg")
      }
    end
    assert_response :unprocessable_entity
  end

  test "should render expired on create if token not found" do
    sign_in @student
    post checkin_path("invalid_token"), params: {
      photo: fixture_file_upload("test_photo.jpg", "image/jpeg")
    }
    assert_response :success
    assert_match /หมดอายุ|expired/i, response.body
  end

  test "should render closed on create if form is not active" do
    sign_in @student
    @checkin_form.update!(active: false)
    post checkin_path(@checkin_form.qr_token), params: {
      checkin_form_id: @checkin_form.id,
      photo: fixture_file_upload("test_photo.jpg", "image/jpeg")
    }
    assert_response :success
    assert_match /ปิด|closed/i, response.body
  end

  test "should render not_enrolled on create if student not in course" do
    sign_in @student
    EnrolledStudent.where(course: @course, student_id: @student.student_id).destroy_all
    post checkin_path(@checkin_form.qr_token), params: {
      checkin_form_id: @checkin_form.id,
      photo: fixture_file_upload("test_photo.jpg", "image/jpeg")
    }
    assert_response :success
    assert_match /ไม่ได้ลงทะเบียน|not enrolled/i, response.body
  end

  test "should redirect on create if already checked in" do
    sign_in @student
    Attendance.create!(
      checkin_form: @checkin_form,
      student_id: @student.student_id,
      name: @student.name,
      photo: { io: StringIO.new("fake"), filename: "test.jpg", content_type: "image/jpeg" }
    )

    assert_no_difference("Attendance.count") do
      post checkin_path(@checkin_form.qr_token), params: {
        checkin_form_id: @checkin_form.id,
        photo: fixture_file_upload("test_photo.jpg", "image/jpeg")
      }
    end
    assert_redirected_to checkin_path(@checkin_form.qr_token)
  end

  test "should not create attendance without photo" do
    sign_in @student
    @checkin_form.update!(mode: :online)

    assert_no_difference("Attendance.count") do
      post checkin_path(@checkin_form.qr_token), params: {
        checkin_form_id: @checkin_form.id
      }
    end
    assert_response :unprocessable_entity
  end

  test "should find checkin_form by id on create" do
    sign_in @student
    @checkin_form.update!(mode: :online)
    old_token = @checkin_form.qr_token
    @checkin_form.refresh_token!

    assert_difference("Attendance.count") do
      post checkin_path(old_token), params: {
        checkin_form_id: @checkin_form.id,
        photo: fixture_file_upload("test_photo.jpg", "image/jpeg")
      }
    end
  end
end

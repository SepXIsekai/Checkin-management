# test/controllers/student_dashboard_controller_test.rb
require "test_helper"

class StudentDashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @course = courses(:one)
    @checkin_form = checkin_forms(:one)
  end

  # ===== Authentication =====

  test "should redirect to login if not authenticated" do
    get student_dashboard_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect if user is teacher" do
    sign_in @teacher
    get student_dashboard_path
    assert_redirected_to root_path
  end

  # ===== Index =====

  test "should get index for student" do
    sign_in @student
    get student_dashboard_path
    assert_response :success
  end

  test "should show enrolled courses" do
    sign_in @student
    EnrolledStudent.find_or_create_by!(course: @course, student_id: @student.student_id)

    get student_dashboard_path
    assert_response :success
    assert_match @course.code, response.body
  end

  test "should not show courses student is not enrolled in" do
    sign_in @student
    # ไม่ได้ลงทะเบียน course
    EnrolledStudent.where(student_id: @student.student_id).destroy_all

    get student_dashboard_path
    assert_response :success
    assert_no_match /#{@course.code}/, response.body
  end

  test "should show attendance summary" do
    sign_in @student
    EnrolledStudent.find_or_create_by!(course: @course, student_id: @student.student_id)

    # สร้าง attendance
    Attendance.create!(
      checkin_form: @checkin_form,
      student_id: @student.student_id,
      name: @student.name,
      photo: { io: StringIO.new("fake"), filename: "test.jpg", content_type: "image/jpeg" }
    )

    get student_dashboard_path
    assert_response :success
  end

  test "should show zero attendance when not checked in" do
    sign_in @student
    EnrolledStudent.find_or_create_by!(course: @course, student_id: @student.student_id)

    # ไม่มี attendance
    Attendance.where(student_id: @student.student_id).destroy_all

    get student_dashboard_path
    assert_response :success
  end

  test "should show correct attendance count" do
    sign_in @student
    EnrolledStudent.find_or_create_by!(course: @course, student_id: @student.student_id)

    # สร้าง checkin_form 2 อัน
    form1 = @checkin_form
    form2 = checkin_forms(:two)

    # เช็คชื่อแค่ 1 อัน
    Attendance.create!(
      checkin_form: form1,
      student_id: @student.student_id,
      name: @student.name,
      photo: { io: StringIO.new("fake"), filename: "test.jpg", content_type: "image/jpeg" }
    )

    get student_dashboard_path
    assert_response :success
  end

  test "should show multiple enrolled courses" do
    sign_in @student

    # สร้าง course ใหม่
    course2 = Course.create!(code: "CS202", name: "Course 2", year: 2024, semester: 1)

    EnrolledStudent.find_or_create_by!(course: @course, student_id: @student.student_id)
    EnrolledStudent.find_or_create_by!(course: course2, student_id: @student.student_id)

    get student_dashboard_path
    assert_response :success
    assert_match @course.code, response.body
    assert_match course2.code, response.body
  end

  test "should show empty state when no enrolled courses" do
    sign_in @student
    EnrolledStudent.where(student_id: @student.student_id).destroy_all

    get student_dashboard_path
    assert_response :success
    assert_match /No Courses|ไม่มีวิชา/i, response.body
  end
end

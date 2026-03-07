# test/controllers/application_controller_test.rb
require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @course = courses(:one)
    @checkin_form = checkin_forms(:one)

    CourseTeacher.find_or_create_by!(course: @course, user: @teacher)
    EnrolledStudent.find_or_create_by!(course: @course, student_id: @student.student_id)
  end

  # ===== after_sign_in_path_for =====

  test "should redirect teacher to courses after sign in" do
    post user_session_path, params: {
      user: {
        email: @teacher.email,
        password: "password123"
      }
    }
    assert_redirected_to courses_path
  end

  test "should redirect student to dashboard after sign in" do
    post user_session_path, params: {
      user: {
        email: @student.email,
        password: "password123"
      }
    }
    assert_redirected_to student_dashboard_path
  end

  # ===== stored_location =====

  test "should redirect to stored location after sign in for student" do
    # เข้าหน้า checkin ก่อน login
    get checkin_path(@checkin_form.qr_token)
    assert_redirected_to new_user_session_path

    # login
    post user_session_path, params: {
      user: {
        email: @student.email,
        password: "password123"
      }
    }

    # ควร redirect กลับไปหน้า checkin
    assert_redirected_to checkin_path(@checkin_form.qr_token)
  end

  test "should redirect to stored location after sign in for teacher" do
    # เข้าหน้า course ก่อน login
    get course_path(@course)
    assert_redirected_to new_user_session_path

    # login
    post user_session_path, params: {
      user: {
        email: @teacher.email,
        password: "password123"
      }
    }

    # ควร redirect กลับไปหน้า course
    assert_redirected_to course_path(@course)
  end

  # ===== after_sign_out_path_for =====

  test "should redirect to login page after sign out" do
    sign_in @student
    delete destroy_user_session_path
    assert_redirected_to new_user_session_path
  end

  # ===== after_sign_up_path_for =====

  test "should redirect student to dashboard after sign up" do
    post user_registration_path, params: {
      user: {
        email: "newstudent@example.com",
        password: "password123",
        password_confirmation: "password123",
        name: "New Student",
        student_id: "new_student_999",
        role: "student"
      }
    }
    assert_redirected_to student_dashboard_path
  end

  test "should redirect teacher to courses after sign up" do
    post user_registration_path, params: {
      user: {
        email: "newteacher@example.com",
        password: "password123",
        password_confirmation: "password123",
        name: "New Teacher",
        role: "teacher",
        secret_code: "ONLYTEACHERCANREGISTER"
      }
    }
    assert_redirected_to courses_path
  end

  test "should redirect to stored location after sign up" do
    # เข้าหน้า checkin ก่อน register
    get checkin_path(@checkin_form.qr_token)
    assert_redirected_to new_user_session_path

    # register
    post user_registration_path, params: {
      user: {
        email: "newstudent2@example.com",
        password: "password123",
        password_confirmation: "password123",
        name: "New Student 2",
        student_id: "new_student_888",
        role: "student"
      }
    }

    # ควร redirect กลับไปหน้า checkin
    assert_redirected_to checkin_path(@checkin_form.qr_token)
  end

  # ===== storable_location? =====

  test "should not store devise controller paths" do
    # เข้าหน้า login
    get new_user_session_path

    # login
    post user_session_path, params: {
      user: {
        email: @student.email,
        password: "password123"
      }
    }

    # ไม่ควร redirect กลับไปหน้า login
    assert_redirected_to student_dashboard_path
  end

  test "should not store non-GET requests" do
    # POST request ไม่ควรถูกเก็บ
    sign_in @student
    sign_out @student

    post user_session_path, params: {
      user: {
        email: @student.email,
        password: "password123"
      }
    }

    assert_redirected_to student_dashboard_path
  end
end

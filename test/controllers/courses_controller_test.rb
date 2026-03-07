# test/controllers/courses_controller_test.rb
require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = users(:teacher)
    @other_teacher = users(:other_teacher)
    @student = users(:student)
    @course = courses(:one)

    CourseTeacher.find_or_create_by!(course: @course, user: @teacher)
  end

  # ===== Authentication =====

  test "should redirect to login if not authenticated" do
    get courses_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect if user is student" do
    sign_in @student
    get courses_path
    assert_redirected_to root_path
  end

  # ===== Index =====

  test "should get index" do
    sign_in @teacher
    get courses_path
    assert_response :success
  end

  test "should only show courses for current teacher" do
    sign_in @teacher
    get courses_path
    assert_response :success
  end

  # ===== Show =====

  test "should show course" do
    sign_in @teacher
    get course_path(@course)
    assert_response :success
  end

  test "should not show course from another teacher" do
    sign_in @other_teacher
    get course_path(@course)
    assert_response :not_found
  rescue ActiveRecord::RecordNotFound
    assert true
  end

  # ===== New =====

  test "should get new" do
    sign_in @teacher
    get new_course_path
    assert_response :success
  end

  # ===== Create =====

  test "should create course" do
    sign_in @teacher
    assert_difference("Course.count") do
      post courses_path, params: {
        course: {
          code: "CS999",
          name: "New Course",
          year: 2024,
          semester: 1
        }
      }
    end
    assert_redirected_to courses_path
  end

  test "should add current teacher to course on create" do
    sign_in @teacher
    post courses_path, params: {
      course: {
        code: "CS888",
        name: "Another Course",
        year: 2024,
        semester: 1
      }
    }
    course = Course.find_by(code: "CS888")
    assert_includes course.teachers, @teacher
  end

  test "should not create course without code" do
    sign_in @teacher
    assert_no_difference("Course.count") do
      post courses_path, params: {
        course: {
          code: "",
          name: "New Course",
          year: 2024,
          semester: 1
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create course without name" do
    sign_in @teacher
    assert_no_difference("Course.count") do
      post courses_path, params: {
        course: {
          code: "CS999",
          name: "",
          year: 2024,
          semester: 1
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # ===== Edit =====

  test "should get edit" do
    sign_in @teacher
    get edit_course_path(@course)
    assert_response :success
  end

  # ===== Update =====

  test "should update course" do
    sign_in @teacher
    patch course_path(@course), params: {
      course: {
        name: "Updated Course Name"
      }
    }
    assert_redirected_to courses_path
    @course.reload
    assert_equal "Updated Course Name", @course.name
  end

  test "should not update course with invalid params" do
    sign_in @teacher
    patch course_path(@course), params: {
      course: {
        code: ""
      }
    }
    assert_response :unprocessable_entity
  end

  # ===== Destroy =====

  test "should destroy course" do
    sign_in @teacher
    assert_difference("Course.count", -1) do
      delete course_path(@course)
    end
    assert_redirected_to courses_path
  end

  # ===== Dashboard =====

  test "should get dashboard" do
    sign_in @teacher
    get dashboard_course_path(@course)
    assert_response :success
  end

  test "should show enrolled students in dashboard" do
    sign_in @teacher
    EnrolledStudent.create!(course: @course, student_id: "12345")
    get dashboard_course_path(@course)
    assert_response :success
  end

  # ===== Export Attendance =====

  test "should export attendance as xlsx" do
    sign_in @teacher
    get export_attendance_course_path(@course, format: :xlsx)
    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.content_type
  end

  test "should include course info in filename" do
    sign_in @teacher
    get export_attendance_course_path(@course, format: :xlsx)
    assert_match /attendance_#{@course.code}/, response.headers["Content-Disposition"]
  end

  # ===== Authorization =====

  test "should not allow other teacher to update course" do
    sign_in @other_teacher
    patch course_path(@course), params: {
      course: { name: "Hacked" }
    }
    assert_response :not_found
  rescue ActiveRecord::RecordNotFound
    assert true
  end

  test "should not allow other teacher to delete course" do
    sign_in @other_teacher
    assert_no_difference("Course.count") do
      delete course_path(@course)
    end
  rescue ActiveRecord::RecordNotFound
    assert true
  end

  test "should not allow other teacher to view dashboard" do
    sign_in @other_teacher
    get dashboard_course_path(@course)
    assert_response :not_found
  rescue ActiveRecord::RecordNotFound
    assert true
  end

  test "should not allow other teacher to export attendance" do
    sign_in @other_teacher
    get export_attendance_course_path(@course, format: :xlsx)
    assert_response :not_found
  rescue ActiveRecord::RecordNotFound
    assert true
  end
end

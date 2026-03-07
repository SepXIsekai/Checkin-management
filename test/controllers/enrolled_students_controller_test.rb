# test/controllers/enrolled_students_controller_test.rb
require "test_helper"

class EnrolledStudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = users(:teacher)
    @other_teacher = users(:other_teacher)
    @student = users(:student)
    @course = courses(:one)

    CourseTeacher.find_or_create_by!(course: @course, user: @teacher)

    # ลบ enrolled students ทั้งหมดก่อนทุก test
    @course.enrolled_students.destroy_all
  end

  # ===== Authentication =====

  test "should redirect to login if not authenticated" do
    get course_enrolled_students_path(@course)
    assert_redirected_to new_user_session_path
  end

  test "should redirect if user is student" do
    sign_in @student
    get course_enrolled_students_path(@course)
    assert_redirected_to root_path
  end

  # ===== Index =====

  test "should get index" do
    sign_in @teacher
    get course_enrolled_students_path(@course)
    assert_response :success
  end

  test "should show enrolled students" do
    sign_in @teacher
    EnrolledStudent.create!(course: @course, student_id: "test123")
    get course_enrolled_students_path(@course)
    assert_response :success
  end

  # ===== Create - Single Student =====

  test "should add single student" do
    sign_in @teacher
    assert_difference("EnrolledStudent.count") do
      post course_enrolled_students_path(@course), params: {
        student_id: "new_student_123"
      }
    end
    assert_redirected_to course_enrolled_students_path(@course)
  end

  test "should not add duplicate student" do
    sign_in @teacher
    EnrolledStudent.create!(course: @course, student_id: "duplicate_id")

    assert_no_difference("EnrolledStudent.count") do
      post course_enrolled_students_path(@course), params: {
        student_id: "duplicate_id"
      }
    end
    assert_redirected_to course_enrolled_students_path(@course)
  end

  test "should strip whitespace from student_id" do
    sign_in @teacher
    post course_enrolled_students_path(@course), params: {
      student_id: "  spaced_id  "
    }
    assert EnrolledStudent.exists?(course: @course, student_id: "spaced_id")
  end

  test "should redirect with alert when no data provided" do
    sign_in @teacher
    post course_enrolled_students_path(@course), params: {}
    assert_redirected_to course_enrolled_students_path(@course)
  end

  # ===== Create - Import File =====

  test "should import students from csv file" do
    sign_in @teacher

    assert_difference("EnrolledStudent.count", 2) do
      post course_enrolled_students_path(@course), params: {
        file: fixture_file_upload("students.csv", "text/csv")
      }
    end
    assert_redirected_to course_enrolled_students_path(@course)
  end

  test "should skip duplicate student_id in import" do
    sign_in @teacher
    EnrolledStudent.create!(course: @course, student_id: "65001")

    # ไฟล์มี 65001 และ 65002 แต่ 65001 มีอยู่แล้ว ควรเพิ่มแค่ 65002
    assert_difference("EnrolledStudent.count", 1) do
      post course_enrolled_students_path(@course), params: {
        file: fixture_file_upload("students.csv", "text/csv")
      }
    end

    assert EnrolledStudent.exists?(course: @course, student_id: "65002")
  end

  # ===== Destroy =====

  test "should destroy enrolled student" do
    sign_in @teacher
    enrolled_student = EnrolledStudent.create!(course: @course, student_id: "delete_me")

    assert_difference("EnrolledStudent.count", -1) do
      delete course_enrolled_student_path(@course, enrolled_student)
    end
    assert_redirected_to course_enrolled_students_path(@course)
  end

  # ===== Destroy All =====

  test "should destroy all enrolled students" do
    sign_in @teacher
    EnrolledStudent.create!(course: @course, student_id: "student1")
    EnrolledStudent.create!(course: @course, student_id: "student2")
    EnrolledStudent.create!(course: @course, student_id: "student3")

    count_before = @course.enrolled_students.count

    delete clear_enrolled_students_course_path(@course)

    assert_equal 0, @course.enrolled_students.count
    assert_redirected_to course_enrolled_students_path(@course)
  end

  # ===== Authorization =====

  test "should not allow other teacher to view enrolled students" do
    sign_in @other_teacher
    get course_enrolled_students_path(@course)
    assert_response :not_found
  rescue ActiveRecord::RecordNotFound
    assert true
  end

  test "should not allow other teacher to add students" do
    sign_in @other_teacher
    assert_no_difference("EnrolledStudent.count") do
      post course_enrolled_students_path(@course), params: {
        student_id: "hacker_student"
      }
    end
  rescue ActiveRecord::RecordNotFound
    assert true
  end

  test "should not allow other teacher to delete students" do
    sign_in @teacher
    enrolled_student = EnrolledStudent.create!(course: @course, student_id: "protected")

    sign_out @teacher
    sign_in @other_teacher

    assert_no_difference("EnrolledStudent.count") do
      delete course_enrolled_student_path(@course, enrolled_student)
    end
  rescue ActiveRecord::RecordNotFound
    assert true
  end

  test "should not allow other teacher to delete all students" do
    sign_in @teacher
    EnrolledStudent.create!(course: @course, student_id: "protected1")
    EnrolledStudent.create!(course: @course, student_id: "protected2")
    initial_count = @course.enrolled_students.count

    sign_out @teacher
    sign_in @other_teacher

    delete clear_enrolled_students_course_path(@course)

    # ควรยังมีอยู่เท่าเดิม
    assert_equal initial_count, @course.enrolled_students.count
  rescue ActiveRecord::RecordNotFound
    assert true
  end
end

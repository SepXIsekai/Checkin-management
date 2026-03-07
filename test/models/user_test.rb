# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # ===== Validations =====

  test "should be valid with valid attributes for student" do
    user = User.new(
      email: "newstudent@example.com",
      password: "password123",
      name: "New Student",
      student_id: "99999",
      role: :student
    )
    assert user.valid?
  end

  test "should be valid with valid attributes for teacher" do
    user = User.new(
      email: "newteacher@example.com",
      password: "password123",
      name: "New Teacher",
      role: :teacher,
      secret_code: "ONLYTEACHERCANREGISTER"
    )
    assert user.valid?
  end

  test "should require name" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      name: nil,
      role: :student,
      student_id: "12345"
    )
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should require email" do
    user = User.new(
      password: "password123",
      name: "Test User",
      role: :student,
      student_id: "12345"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    existing = users(:student)
    user = User.new(
      email: existing.email,
      password: "password123",
      name: "Test User",
      role: :student,
      student_id: "99999"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  # ===== Student ID Validations =====

  test "should require student_id for student role" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      name: "Test Student",
      role: :student,
      student_id: nil
    )
    assert_not user.valid?
    assert_includes user.errors[:student_id], "Student ID is required."
  end

  test "should not require student_id for teacher role" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      name: "Test Teacher",
      role: :teacher,
      student_id: nil,
      secret_code: "ONLYTEACHERCANREGISTER"
    )
    assert user.valid?
  end

  test "should require unique student_id" do
    existing = users(:student)
    user = User.new(
      email: "new@example.com",
      password: "password123",
      name: "Test Student",
      role: :student,
      student_id: existing.student_id
    )
    assert_not user.valid?
    assert_includes user.errors[:student_id], "This student ID is already registered."
  end

  test "should allow blank student_id for uniqueness check" do
    user1 = User.create!(
      email: "teacher1@example.com",
      password: "password123",
      name: "Teacher 1",
      role: :teacher,
      secret_code: "ONLYTEACHERCANREGISTER"
    )
    user2 = User.new(
      email: "teacher2@example.com",
      password: "password123",
      name: "Teacher 2",
      role: :teacher,
      secret_code: "ONLYTEACHERCANREGISTER"
    )
    assert user2.valid?
  end

  # ===== Secret Code Validations =====

  test "should require correct secret_code for teacher on create" do
    user = User.new(
      email: "teacher@example.com",
      password: "password123",
      name: "Teacher",
      role: :teacher,
      secret_code: "WRONGCODE"
    )
    assert_not user.valid?
    assert_includes user.errors[:secret_code], "The instructor ID is incorrect."
  end

  test "should reject teacher without secret_code" do
    user = User.new(
      email: "teacher@example.com",
      password: "password123",
      name: "Teacher",
      role: :teacher,
      secret_code: nil
    )
    assert_not user.valid?
    assert_includes user.errors[:secret_code], "The instructor ID is incorrect."
  end

  test "should not require secret_code for student" do
    user = User.new(
      email: "newstudent123@example.com",
      password: "password123",
      name: "Student",
      role: :student,
      student_id: "unique_id_#{SecureRandom.hex(4)}",
      secret_code: nil
    )
    assert user.valid?, user.errors.full_messages.join(", ")
  end

  # ===== Role Enum =====

  test "should have student role by default" do
    user = User.new(role: :student)
    assert user.student?
  end

  test "should be able to set teacher role" do
    user = User.new(role: :teacher)
    assert user.teacher?
  end

  # ===== Associations =====

  test "should have many course_teachers" do
    teacher = users(:teacher)
    assert_respond_to teacher, :course_teachers
  end

  test "should have many teaching_courses through course_teachers" do
    teacher = users(:teacher)
    assert_respond_to teacher, :teaching_courses
  end

  test "should destroy course_teachers when user is destroyed" do
    teacher = users(:teacher)

    unless teacher.course_teachers.any?
      course = courses(:one)
      CourseTeacher.find_or_create_by!(user: teacher, course: course)
    end

    teacher_course_count = teacher.course_teachers.count

    assert_difference("CourseTeacher.count", -teacher_course_count) do
      teacher.destroy
    end
  end

  # ===== Password Validations (Devise) =====

  test "should require password with minimum length" do
    user = User.new(
      email: "test@example.com",
      password: "12345",
      name: "Test",
      role: :student,
      student_id: "12345"
    )
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "should require password" do
    user = User.new(
      email: "test@example.com",
      password: nil,
      name: "Test",
      role: :student,
      student_id: "12345"
    )
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end
end

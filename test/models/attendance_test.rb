# test/models/attendance_test.rb
require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  setup do
    @checkin_form = checkin_forms(:one)
    @photo = create_test_photo
  end

  # ===== Validations =====

  test "should be valid with valid attributes" do
    attendance = Attendance.new(
      checkin_form: @checkin_form,
      student_id: "99999",
      name: "Test Student"
    )
    attendance.photo.attach(@photo)
    assert attendance.valid?, attendance.errors.full_messages.join(", ")
  end

  test "should require student_id" do
    attendance = Attendance.new(
      checkin_form: @checkin_form,
      student_id: nil,
      name: "Test Student"
    )
    assert_not attendance.valid?
    assert_includes attendance.errors[:student_id], "can't be blank"
  end

  test "should require name" do
    attendance = Attendance.new(
      checkin_form: @checkin_form,
      student_id: "12345",
      name: nil
    )
    assert_not attendance.valid?
    assert_includes attendance.errors[:name], "can't be blank"
  end

  test "should require photo" do
    attendance = Attendance.new(
      checkin_form: @checkin_form,
      student_id: "12345",
      name: "Test Student"
    )
    assert_not attendance.valid?
    assert_includes attendance.errors[:photo], "can't be blank"
  end

  test "should require unique student_id per checkin_form" do
    first_attendance = Attendance.new(
      checkin_form: @checkin_form,
      student_id: "duplicate_id",
      name: "First Student"
    )
    first_attendance.photo.attach(@photo)
    first_attendance.save!

    second_attendance = Attendance.new(
      checkin_form: @checkin_form,
      student_id: "duplicate_id",
      name: "Second Student"
    )
    second_attendance.photo.attach(create_test_photo)

    assert_not second_attendance.valid?
    assert_includes second_attendance.errors[:student_id], "เช็คชื่อไปแล้ว"
  end

  test "should allow same student_id in different checkin_forms" do
    other_checkin_form = checkin_forms(:two)

    first_attendance = Attendance.new(
      checkin_form: @checkin_form,
      student_id: "same_id",
      name: "Student"
    )
    first_attendance.photo.attach(@photo)
    first_attendance.save!

    second_attendance = Attendance.new(
      checkin_form: other_checkin_form,
      student_id: "same_id",
      name: "Student"
    )
    second_attendance.photo.attach(create_test_photo)

    assert second_attendance.valid?, second_attendance.errors.full_messages.join(", ")
  end

  # ===== Associations =====

  test "should belong to checkin_form" do
    attendance = Attendance.new
    assert_respond_to attendance, :checkin_form
  end

  test "should have one attached photo" do
    attendance = Attendance.new
    assert_respond_to attendance, :photo
  end

  # ===== Callbacks =====

  test "should set checked_at before create" do
    attendance = Attendance.new(
      checkin_form: @checkin_form,
      student_id: "callback_test",
      name: "Callback Test"
    )
    attendance.photo.attach(create_test_photo)

    assert_nil attendance.checked_at
    attendance.save!
    assert_not_nil attendance.checked_at
  end

  test "should not override checked_at if already set" do
    custom_time = 1.hour.ago
    attendance = Attendance.new(
      checkin_form: @checkin_form,
      student_id: "custom_time_test",
      name: "Custom Time Test",
      checked_at: custom_time
    )
    attendance.photo.attach(create_test_photo)
    attendance.save!

    assert_in_delta custom_time, attendance.checked_at, 1.second
  end

  private

  def create_test_photo
    {
      io: StringIO.new("fake image data"),
      filename: "test_photo.jpg",
      content_type: "image/jpeg"
    }
  end
end

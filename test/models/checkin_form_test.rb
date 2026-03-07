# test/models/checkin_form_test.rb
require "test_helper"

class CheckinFormTest < ActiveSupport::TestCase
  setup do
    @course = courses(:one)
  end

  # ===== Validations =====

  test "should be valid with valid attributes for online mode" do
    checkin_form = CheckinForm.new(
      course: @course,
      title: "Test Session",
      mode: :online
    )
    assert checkin_form.valid?, checkin_form.errors.full_messages.join(", ")
  end

  test "should be valid with valid attributes for onsite mode" do
    checkin_form = CheckinForm.new(
      course: @course,
      title: "Test Session",
      mode: :onsite,
      latitude: 13.7563,
      longitude: 100.5018,
      radius: 100
    )
    assert checkin_form.valid?, checkin_form.errors.full_messages.join(", ")
  end

  test "should require title" do
    checkin_form = CheckinForm.new(
      course: @course,
      title: nil,
      mode: :online
    )
    assert_not checkin_form.valid?
    assert_includes checkin_form.errors[:title], "can't be blank"
  end

  test "should require latitude for onsite mode" do
    checkin_form = CheckinForm.new(
      course: @course,
      title: "Test",
      mode: :onsite,
      latitude: nil,
      longitude: 100.5018
    )
    assert_not checkin_form.valid?
    assert_includes checkin_form.errors[:latitude], "can't be blank"
  end

  test "should require longitude for onsite mode" do
    checkin_form = CheckinForm.new(
      course: @course,
      title: "Test",
      mode: :onsite,
      latitude: 13.7563,
      longitude: nil
    )
    assert_not checkin_form.valid?
    assert_includes checkin_form.errors[:longitude], "can't be blank"
  end

  test "should not require latitude for online mode" do
    checkin_form = CheckinForm.new(
      course: @course,
      title: "Test",
      mode: :online,
      latitude: nil
    )
    assert checkin_form.valid?, checkin_form.errors.full_messages.join(", ")
  end

  test "should require unique qr_token" do
    existing = checkin_forms(:one)
    checkin_form = CheckinForm.new(
      course: @course,
      title: "Test",
      mode: :online,
      qr_token: existing.qr_token
    )
    assert_not checkin_form.valid?
    assert_includes checkin_form.errors[:qr_token], "has already been taken"
  end

  # ===== Associations =====

  test "should belong to course" do
    checkin_form = CheckinForm.new
    assert_respond_to checkin_form, :course
  end

  test "should have many attendances" do
    checkin_form = checkin_forms(:one)
    assert_respond_to checkin_form, :attendances
  end

  test "should destroy attendances when destroyed" do
    checkin_form = CheckinForm.create!(
      course: @course,
      title: "Delete Test",
      mode: :online
    )
    Attendance.create!(
      checkin_form: checkin_form,
      student_id: "delete_test",
      name: "Delete Test",
      photo: { io: StringIO.new("fake"), filename: "test.jpg", content_type: "image/jpeg" }
    )

    assert_difference("Attendance.count", -1) do
      checkin_form.destroy
    end
  end

  # ===== Callbacks =====

  test "should generate qr_token before create" do
    checkin_form = CheckinForm.new(
      course: @course,
      title: "Test",
      mode: :online
    )
    assert_nil checkin_form.qr_token
    checkin_form.save!
    assert_not_nil checkin_form.qr_token
  end

  test "should set token_expires_at before create" do
    checkin_form = CheckinForm.new(
      course: @course,
      title: "Test",
      mode: :online
    )
    assert_nil checkin_form.token_expires_at
    checkin_form.save!
    assert_not_nil checkin_form.token_expires_at
  end

  # ===== Enum =====

  test "should have online mode" do
    checkin_form = CheckinForm.new(mode: :online)
    assert checkin_form.online?
  end

  test "should have onsite mode" do
    checkin_form = CheckinForm.new(mode: :onsite)
    assert checkin_form.onsite?
  end

  # ===== Instance Methods =====

  test "open? should return true when active" do
    checkin_form = CheckinForm.new(active: true)
    assert checkin_form.open?
  end

  test "open? should return false when not active" do
    checkin_form = CheckinForm.new(active: false)
    assert_not checkin_form.open?
  end

  test "token_expired? should return true when token_expires_at is nil" do
    checkin_form = CheckinForm.new(token_expires_at: nil)
    assert checkin_form.token_expired?
  end

  test "token_expired? should return true when token_expires_at is in the past" do
    checkin_form = CheckinForm.new(token_expires_at: 1.minute.ago)
    assert checkin_form.token_expired?
  end

  test "token_expired? should return false when token_expires_at is in the future" do
    checkin_form = CheckinForm.new(token_expires_at: 1.minute.from_now)
    assert_not checkin_form.token_expired?
  end

  test "refresh_token! should update qr_token and token_expires_at" do
    checkin_form = CheckinForm.create!(
      course: @course,
      title: "Refresh Test",
      mode: :online
    )
    old_token = checkin_form.qr_token
    old_expires_at = checkin_form.token_expires_at

    checkin_form.refresh_token!
    checkin_form.reload

    assert_not_equal old_token, checkin_form.qr_token
    assert checkin_form.token_expires_at > old_expires_at
  end

  # ===== checkin_url =====

  test "checkin_url should use http for localhost" do
    checkin_form = checkin_forms(:one)
    url = checkin_form.checkin_url("localhost:3000")
    assert_match %r{^http://localhost:3000/checkin/}, url
  end

  test "checkin_url should use https for ngrok" do
    checkin_form = checkin_forms(:one)
    url = checkin_form.checkin_url("abc123.ngrok-free.app")
    assert_match %r{^https://abc123.ngrok-free.app/checkin/}, url
  end

  test "checkin_url should include qr_token" do
    checkin_form = checkin_forms(:one)
    url = checkin_form.checkin_url("localhost:3000")
    assert_includes url, checkin_form.qr_token
  end

  # ===== qr_code_svg =====

  test "qr_code_svg should return svg string" do
    checkin_form = checkin_forms(:one)
    svg = checkin_form.qr_code_svg("localhost:3000")
    assert_match /<svg/, svg
    assert_match /<\/svg>/, svg
  end

  # ===== within_radius? =====

  test "within_radius? should return true for online mode" do
    checkin_form = CheckinForm.new(mode: :online)
    assert checkin_form.within_radius?(0, 0)
  end

  test "within_radius? should return false when latitude is nil" do
    checkin_form = CheckinForm.new(mode: :onsite, latitude: nil, longitude: 100.0)
    assert_not checkin_form.within_radius?(13.0, 100.0)
  end

  test "within_radius? should return false when longitude is nil" do
    checkin_form = CheckinForm.new(mode: :onsite, latitude: 13.0, longitude: nil)
    assert_not checkin_form.within_radius?(13.0, 100.0)
  end

  test "within_radius? should return true when user is within radius" do
    checkin_form = CheckinForm.new(
      mode: :onsite,
      latitude: 13.7563,
      longitude: 100.5018,
      radius: 100
    )
    # Same location
    assert checkin_form.within_radius?(13.7563, 100.5018)
  end

  test "within_radius? should return false when user is outside radius" do
    checkin_form = CheckinForm.new(
      mode: :onsite,
      latitude: 13.7563,
      longitude: 100.5018,
      radius: 100
    )
    # Far away location
    assert_not checkin_form.within_radius?(14.0, 101.0)
  end

  test "within_radius? should use default radius of 100 when radius is nil" do
    checkin_form = CheckinForm.new(
      mode: :onsite,
      latitude: 13.7563,
      longitude: 100.5018,
      radius: nil
    )
    # Same location should be within default 100m
    assert checkin_form.within_radius?(13.7563, 100.5018)
  end

  # ===== Scope =====

  test "active scope should return only active forms" do
    active_form = CheckinForm.create!(course: @course, title: "Active", mode: :online, active: true)
    inactive_form = CheckinForm.create!(course: @course, title: "Inactive", mode: :online, active: false)

    active_forms = CheckinForm.active
    assert_includes active_forms, active_form
    assert_not_includes active_forms, inactive_form
  end
end

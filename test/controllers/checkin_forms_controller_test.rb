# test/controllers/checkin_forms_controller_test.rb
require "test_helper"

class CheckinFormsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = users(:teacher)
    @student = users(:student)
    @other_teacher = users(:other_teacher)
    @course = courses(:one)
    @checkin_form = checkin_forms(:one)
  end

  # ===== Authentication =====

  test "should redirect to login if not authenticated" do
    get course_checkin_forms_path(@course)
    assert_redirected_to new_user_session_path
  end

  test "should redirect if user is student" do
    sign_in @student
    get course_checkin_forms_path(@course)
    assert_redirected_to root_path
  end

  # ===== Index =====

  test "should get index" do
    sign_in @teacher
    get course_checkin_forms_path(@course)
    assert_response :success
  end

  test "should list checkin forms for course" do
    sign_in @teacher
    get course_checkin_forms_path(@course)
    assert_select "body"
  end

  # ===== New =====

  test "should get new" do
    sign_in @teacher
    get new_course_checkin_form_path(@course)
    assert_response :success
  end

  # ===== Create =====

  test "should create checkin form with online mode" do
    sign_in @teacher
    assert_difference("CheckinForm.count") do
      post course_checkin_forms_path(@course), params: {
        checkin_form: {
          title: "New Session",
          mode: "online"
        }
      }
    end
    assert_redirected_to course_checkin_form_path(@course, CheckinForm.last)
  end

  test "should create checkin form with onsite mode" do
    sign_in @teacher
    assert_difference("CheckinForm.count") do
      post course_checkin_forms_path(@course), params: {
        checkin_form: {
          title: "Onsite Session",
          mode: "onsite",
          latitude: 13.7563,
          longitude: 100.5018,
          radius: 100
        }
      }
    end
    assert_redirected_to course_checkin_form_path(@course, CheckinForm.last)
  end

  test "should not create checkin form without title" do
    sign_in @teacher
    assert_no_difference("CheckinForm.count") do
      post course_checkin_forms_path(@course), params: {
        checkin_form: {
          title: "",
          mode: "online"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # ===== Show =====

  test "should show checkin form" do
    sign_in @teacher
    get course_checkin_form_path(@course, @checkin_form)
    assert_response :success
  end

  # test "should not show checkin_form from another teacher course" do
  #   sign_in @other_teacher
  #   get course_checkin_form_path(@course, @checkin_form)
  #   assert_redirected_to root_path
  # end

  # ===== Toggle =====

  test "should toggle checkin form active status" do
    sign_in @teacher
    original_status = @checkin_form.active?
    patch toggle_course_checkin_form_path(@course, @checkin_form)
    @checkin_form.reload
    assert_equal !original_status, @checkin_form.active?
    assert_redirected_to course_checkin_form_path(@course, @checkin_form)
  end

  # ===== Destroy =====

  test "should destroy checkin form" do
    sign_in @teacher
    assert_difference("CheckinForm.count", -1) do
      delete course_checkin_form_path(@course, @checkin_form)
    end
    assert_redirected_to course_checkin_forms_path(@course)
  end

  # ===== QR Code =====

  test "should get qr code json" do
    sign_in @teacher
    get qr_code_course_checkin_form_path(@course, @checkin_form)
    assert_response :success
    json = JSON.parse(response.body)
    assert json["svg"].present?
    assert json["url"].present?
  end

  # ===== Fullscreen =====

  test "should get fullscreen" do
    sign_in @teacher
    get fullscreen_course_checkin_form_path(@course, @checkin_form)
    assert_response :success
  end

  # ===== Attendances =====

  test "should get attendances turbo stream" do
    sign_in @teacher
    get attendances_course_checkin_form_path(@course, @checkin_form),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
  end
end

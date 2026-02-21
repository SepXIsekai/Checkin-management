# app/controllers/checkins_controller.rb
class CheckinsController < ApplicationController
  layout "student"

  before_action :authenticate_user!
  before_action :require_student
  before_action :set_checkin_form

  def new
    if !@checkin_form.open?
      render :closed
      return
    end

    unless @checkin_form.course.enrolled_students.exists?(student_id: current_user.student_id)
      render :not_enrolled
      return
    end

    if @checkin_form.attendances.exists?(student_id: current_user.student_id)
      @attendance = @checkin_form.attendances.find_by(student_id: current_user.student_id)
      render :already_checked
      return
    end

    @attendance = @checkin_form.attendances.new(
      student_id: current_user.student_id,
      name: current_user.name
    )
  end

  def create
    if !@checkin_form.open?
      render :closed
      return
    end

    unless @checkin_form.course.enrolled_students.exists?(student_id: current_user.student_id)
      render :not_enrolled
      return
    end

    if @checkin_form.attendances.exists?(student_id: current_user.student_id)
      redirect_to checkin_success_path(@checkin_form.qr_token)
      return
    end

    # เช็ค location ถ้าเป็น onsite
    if @checkin_form.onsite?
      user_lat = params[:latitude].to_f
      user_lng = params[:longitude].to_f

      unless @checkin_form.within_radius?(user_lat, user_lng)
        @attendance = @checkin_form.attendances.new
        @attendance.errors.add(:base, "คุณไม่ได้อยู่ในบริเวณห้องเรียน")
        render :new, status: :unprocessable_entity
        return
      end
    end

    @attendance = @checkin_form.attendances.new(
      student_id: current_user.student_id,
      name: current_user.name,
      photo: params[:photo]
    )

    if @attendance.save
      redirect_to checkin_success_path(@checkin_form.qr_token)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def success
    @attendance = @checkin_form.attendances.find_by(student_id: current_user.student_id)
  end

  private

  def set_checkin_form
    @checkin_form = CheckinForm.find_by!(qr_token: params[:token])
    @course = @checkin_form.course
  end

  def require_student
    unless current_user.student?
      redirect_to root_path, alert: "เฉพาะนักศึกษาเท่านั้น"
    end
  end
end

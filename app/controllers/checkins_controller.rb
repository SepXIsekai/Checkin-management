# app/controllers/checkins_controller.rb
class CheckinsController < ApplicationController
  layout "student"

  before_action :authenticate_user!
  before_action :require_student
  before_action :set_checkin_form

  def new
    unless @checkin_form
      render :expired
      return
    end

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
      render :success
      return
    end

    @attendance = @checkin_form.attendances.new(
      student_id: current_user.student_id,
      name: current_user.name
    )
  end

  def create
    unless @checkin_form
      render :expired
      return
    end

    if !@checkin_form.open?
      render :closed
      return
    end

    unless @checkin_form.course.enrolled_students.exists?(student_id: current_user.student_id)
      render :not_enrolled
      return
    end

    if @checkin_form.attendances.exists?(student_id: current_user.student_id)
      redirect_to checkin_path(@checkin_form.qr_token)
      return
    end

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
      redirect_to checkin_path(@checkin_form.qr_token)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_checkin_form
    if params[:checkin_form_id].present?
      @checkin_form = CheckinForm.find_by(id: params[:checkin_form_id])
    else
      @checkin_form = CheckinForm.find_by(qr_token: params[:token])
    end
    @course = @checkin_form&.course
  end

  def require_student
    unless current_user.student?
      redirect_to root_path, alert: "เฉพาะนักศึกษาเท่านั้น"
    end
  end
end

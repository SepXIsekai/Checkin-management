class CheckinFormsController < ApplicationController
  layout "teacher"

  before_action :authenticate_user!
  before_action :require_teacher
  before_action :set_course
  before_action :set_checkin_form, only: [ :show, :destroy, :toggle, :qr_code, :fullscreen ]

  def index
    @checkin_forms = @course.checkin_forms.order(created_at: :desc)
  end

  def new
    @checkin_form = @course.checkin_forms.new
  end

  def create
    @checkin_form = @course.checkin_forms.new(checkin_form_params)

    if @checkin_form.save
      redirect_to course_checkin_form_path(@course, @checkin_form), notice: "สร้างฟอร์มเช็คชื่อสำเร็จ"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @host = request.host_with_port
  end

  def destroy
    @checkin_form.destroy
    redirect_to course_checkin_forms_path(@course), notice: "ลบฟอร์มเช็คชื่อสำเร็จ"
  end

  def toggle
    @checkin_form.update(active: !@checkin_form.active)
    redirect_to course_checkin_form_path(@course, @checkin_form), notice: "อัพเดทสถานะสำเร็จ"
  end

  def qr_code
    host = request.host_with_port
    @checkin_form.refresh_token! if @checkin_form.token_expired?

    render json: {
      svg: @checkin_form.qr_code_svg(host),
      url: @checkin_form.checkin_url(host),
      expires_in: @checkin_form.token_expires_at ? (@checkin_form.token_expires_at - Time.current).to_i : 30
    }
  end

  def fullscreen
    @host = request.host_with_port
    render layout: false
  end

  private

  def set_course
    @course = current_user.teaching_courses.find(params[:course_id])
  end

  def set_checkin_form
    @checkin_form = @course.checkin_forms.find(params[:id])
  end

  def checkin_form_params
    params.require(:checkin_form).permit(:title, :mode, :latitude, :longitude, :radius)
  end

  def require_teacher
    unless current_user.teacher?
      redirect_to root_path, alert: "เฉพาะอาจารย์เท่านั้น"
    end
  end
end

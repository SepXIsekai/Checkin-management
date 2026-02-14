# app/controllers/courses_controller.rb
class CoursesController < ApplicationController
  layout "teacher"

  before_action :authenticate_user!
  before_action :require_teacher
  before_action :set_course, only: %i[show edit update destroy]

  def index
    @courses = current_user.teaching_courses
  end

  def show
    @checkin_forms = @course.checkin_forms.order(created_at: :desc).limit(3)
  end

  def new
    @course = Course.new
    @course.course_teachers.build
  end

  def edit
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      if @course.teachers.empty?
        @course.teachers << current_user
      end
      redirect_to courses_path, notice: "สร้างวิชาสำเร็จ"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @course.update(course_params)
      redirect_to courses_path, notice: "แก้ไขวิชาสำเร็จ"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_path, notice: "ลบวิชาสำเร็จ"
  end

  private

  def set_course
    @course = current_user.teaching_courses.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:code, :name, :year, :semester,
      course_teachers_attributes: [ :id, :user_id, :_destroy ])
  end

  def require_teacher
    unless current_user.teacher?
      redirect_to root_path, alert: "เฉพาะอาจารย์เท่านั้น"
    end
  end
end

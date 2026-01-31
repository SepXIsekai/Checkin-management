# app/controllers/courses_controller.rb
class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher
  before_action :set_course, only: %i[show edit update destroy]

  def index
    @courses = current_user.teaching_courses
  end

  def show
  end

  def new
    @course = Course.new
  end

  def edit
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      # เพิ่ม current_user เป็นอาจารย์ด้วยถ้าไม่ได้เลือก
      unless @course.teacher_ids.include?(current_user.id)
        @course.teachers << current_user
      end
      redirect_to @course, notice: "สร้างวิชาสำเร็จ"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @course.update(course_params)
      redirect_to @course, notice: "แก้ไขวิชาสำเร็จ"
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
    params.require(:course).permit(:code, :name, :year, :semester, teacher_ids: [])
  end

  def require_teacher
    unless current_user.teacher?
      redirect_to root_path, alert: "เฉพาะอาจารย์เท่านั้น"
    end
  end
end

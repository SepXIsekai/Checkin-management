# app/controllers/courses_controller.rb
class CoursesController < ApplicationController
  layout "teacher"

  before_action :authenticate_user!
  before_action :require_teacher
  before_action :set_course, only: %i[show edit update destroy dashboard export_attendance]

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

  def dashboard
    @checkin_forms = @course.checkin_forms.order(:created_at)
    @enrolled_students = @course.enrolled_students.order(:student_id)
  end

  def export_attendance
    @checkin_forms = @course.checkin_forms.order(:created_at)
    @enrolled_students = @course.enrolled_students.order(:student_id)

    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: "รายงานเช็คชื่อ") do |sheet|
      title_style = sheet.styles.add_style(b: true, sz: 14)
      header_style = sheet.styles.add_style(b: true, bg_color: "DDDDDD", alignment: { horizontal: :center })

      sheet.add_row [ "รายงานการเช็คชื่อ - #{@course.code} #{@course.name}" ], style: title_style
      sheet.add_row [ "ปีการศึกษา #{@course.year} ภาคเรียนที่ #{@course.semester}" ]
      sheet.add_row []

      headers = [ "ลำดับ", "รหัสนักศึกษา" ]
      @checkin_forms.each do |form|
        headers << form.title
      end
      headers << "รวม"

      sheet.add_row headers, style: header_style

      @enrolled_students.each_with_index do |student, index|
        count = @checkin_forms.count { |form| form.attendances.exists?(student_id: student.student_id) }

        row = [ index + 1, student.student_id ]

        @checkin_forms.each do |form|
          if form.attendances.exists?(student_id: student.student_id)
            row << 1
          else
            row << 0
          end
        end

        row << count

        sheet.add_row row
      end

      sheet.add_row []
      sheet.add_row [ "จำนวนครั้งเช็คชื่อทั้งหมด: #{@checkin_forms.count} ครั้ง" ]
      sheet.add_row [ "จำนวนนักศึกษา: #{@enrolled_students.count} คน" ]
    end

    send_data p.to_stream.read,
      filename: "attendance_#{@course.code}_#{Date.today}.xlsx",
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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

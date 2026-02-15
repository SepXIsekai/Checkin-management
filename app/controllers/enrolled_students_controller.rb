# app/controllers/enrolled_students_controller.rb
class EnrolledStudentsController < ApplicationController
  layout "teacher"

  before_action :authenticate_user!
  before_action :require_teacher
  before_action :set_course

  def index
    @enrolled_students = @course.enrolled_students.order(:student_id)

    @attendance_summary = Attendance.joins(:checkin_form).where(checkin_forms: { course_id: @course.id }).group(:student_id).count
  end

  def create
    if params[:file].present?
      import_from_file(params[:file])
      redirect_to course_enrolled_students_path(@course), notice: "Import นักศึกษาสำเร็จ"
    elsif params[:student_id].present?
      add_single_student
      redirect_to course_enrolled_students_path(@course), notice: "เพิ่มนักศึกษาสำเร็จ"
    else
      redirect_to course_enrolled_students_path(@course), alert: "กรุณากรอกข้อมูล"
    end
  end

  def destroy
    @enrolled_student = @course.enrolled_students.find(params[:id])
    @enrolled_student.destroy
    redirect_to course_enrolled_students_path(@course), notice: "ลบนักศึกษาสำเร็จ"
  end

  def destroy_all
    @course.enrolled_students.destroy_all
    redirect_to course_enrolled_students_path(@course), notice: "ลบนักศึกษาทั้งหมดสำเร็จ"
  end

  def export
    @checkin_forms = @course.checkin_forms.order(:created_at)
    @enrolled_students = @course.enrolled_students.order(:student_id)

    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(name: "รายงานเช็คชื่อ") do |sheet|
      title_style = sheet.styles.add_style(b: true, sz: 14)
      header_style = sheet.styles.add_style(b: true, bg_color: "DDDDDD", alignment: { horizontal: :center })
      center_style = sheet.styles.add_style(alignment: { horizontal: :center })

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
        row = [ index + 1, student.student_id ]
        count = 0

        @checkin_forms.each do |form|
          if form.attendances.exists?(student_id: student.student_id)
            row << "✓"
            count += 1
          else
            row << "-"
          end
        end

        row << count

        sheet.add_row row, style: [ nil, nil ] + Array.new(@checkin_forms.count, center_style) + [ center_style ]
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
    course_id = params[:course_id] || params[:id]
    @course = current_user.teaching_courses.find(course_id)
  end

  def require_teacher
    unless current_user.teacher?
      redirect_to root_path, alert: "เฉพาะอาจารย์เท่านั้น"
    end
  end

  def import_from_file(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1).map { |h| h.to_s.strip.downcase }

    # หา index ของ column student_id
    student_id_index = header.index("student_id") || header.index("รหัสนักศึกษา") || 0

    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      student_id = row[student_id_index]
      next if student_id.blank?

      @course.enrolled_students.find_or_create_by(student_id: student_id.to_s.strip)
    end
  end

  def add_single_student
    @course.enrolled_students.find_or_create_by(student_id: params[:student_id].strip)
  end
end

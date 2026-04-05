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
    elsif params[:student_id].present?
      add_single_student
    else
      redirect_to course_enrolled_students_path(@course), alert: "กรุณาระบุข้อมูล"
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

  private

  def set_course
    course_id = params[:course_id] || params[:id]
    @course = current_user.teaching_courses.find(course_id)
  end

  def require_teacher
    unless current_user.teacher?
      redirect_to root_path, alert: "Teachers only"
    end
  end

  def import_from_file(file)
    # ตรวจสอบ file extension
    extension = File.extname(file.original_filename).downcase
    unless %w[.xlsx .xls .csv].include?(extension)
      redirect_to course_enrolled_students_path(@course), alert: "รองรับเฉพาะไฟล์ .xlsx, .xls, .csv"
      return
    end

    begin
      spreadsheet = Roo::Spreadsheet.open(file.path, extension: extension.delete("."))
    rescue => e
      redirect_to course_enrolled_students_path(@course), alert: "ไม่สามารถอ่านไฟล์ได้: #{e.message}"
      return
    end

    # ตรวจสอบว่ามีข้อมูลไหม
    if spreadsheet.last_row.nil? || spreadsheet.last_row < 2
      redirect_to course_enrolled_students_path(@course), alert: "ไฟล์ไม่มีข้อมูลนักศึกษา"
      return
    end

    header = spreadsheet.row(1).map { |h| h.to_s.strip.downcase }
    student_id_index = header.index("student_id") || header.index("รหัสนักศึกษา")

    # ตรวจสอบ header
    if student_id_index.nil?
      redirect_to course_enrolled_students_path(@course), alert: "ไม่พบคอลัมน์ 'student_id' หรือ 'รหัสนักศึกษา' ในไฟล์"
      return
    end

    imported_count = 0
    skipped_count = 0

    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      student_id = row[student_id_index]
      next if student_id.blank?

      student = @course.enrolled_students.find_or_initialize_by(student_id: student_id.to_s.strip)
      if student.new_record?
        if student.save
          imported_count += 1
        end
      else
        skipped_count += 1
      end
    end

    message = "นำเข้าสำเร็จ #{imported_count} คน"
    message += ", ข้าม #{skipped_count} คน (มีอยู่แล้ว)" if skipped_count > 0

    redirect_to course_enrolled_students_path(@course), notice: message

  rescue => e
    redirect_to course_enrolled_students_path(@course), alert: "เกิดข้อผิดพลาด: #{e.message}"
  end

  def add_single_student
    student = @course.enrolled_students.new(student_id: params[:student_id].strip)

    if student.save
      redirect_to course_enrolled_students_path(@course), notice: "เพิ่มนักศึกษาสำเร็จ"
    else
      redirect_to course_enrolled_students_path(@course), alert: student.errors.messages.values.flatten.join(", ")
    end
  end
end

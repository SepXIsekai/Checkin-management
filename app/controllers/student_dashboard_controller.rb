# app/controllers/student_dashboard_controller.rb
class StudentDashboardController < ApplicationController
  layout "student"

  before_action :authenticate_user!
  before_action :require_student

  def index
    @enrolled_courses = Course.joins(:enrolled_students)
                              .where(enrolled_students: { student_id: current_user.student_id })
                              .distinct

    @attendance_summary = {}
    @enrolled_courses.each do |course|
      total_sessions = course.checkin_forms.count
      attended = Attendance.joins(:checkin_form)
                           .where(checkin_forms: { course_id: course.id })
                           .where(student_id: current_user.student_id)
                           .count
      @attendance_summary[course.id] = { attended: attended, total: total_sessions }
    end
  end

  private

  def require_student
    unless current_user.student?
      redirect_to root_path, alert: "เฉพาะนักศึกษาเท่านั้น"
    end
  end
end

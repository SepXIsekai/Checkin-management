class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :course_teachers, dependent: :destroy
  has_many :teaching_courses, through: :course_teachers, source: :course
  enum :role, { student: 0, teacher: 1 }

  attr_accessor :secret_code

  validates :name, presence: true
  validates :student_id, uniqueness: { message: "รหัสนักศึกษานี้มีในระบบแล้ว" }, allow_blank: true
  validates :student_id, presence: { message: "กรุณากรอกรหัสนักศึกษา" }, if: :student?

  validate :verify_secret_code, on: :create

  private

  def verify_secret_code
    if teacher? && secret_code != "ONLYTEACHERCANREGISTER"
      errors.add(:secret_code, "รหัสอาจารย์ไม่ถูกต้อง")
    end
  end
end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { student: 0, teacher: 1 }

  attr_accessor :secret_code

  validates :name, presence: true
  validates :student_id, presence: true, if: :student?

  validate :verify_secret_code, on: :create

  private

  def verify_secret_code
    if teacher? && secret_code != "ONLYTEACHERCANREGISTER"
      errors.add(:secret_code, "รหัสอาจารย์ไม่ถูกต้อง")
    end
  end
end

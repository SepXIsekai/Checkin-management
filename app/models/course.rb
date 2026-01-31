class Course < ApplicationRecord
  has_many :course_teachers, dependent: :destroy
  has_many :teachers, through: :course_teachers, source: :user

  has_many :enrolled_students, dependent: :destroy

  validates :code, presence: true
  validates :name, presence: true
  validates :year, presence: true
  validates :semester, presence: true
end

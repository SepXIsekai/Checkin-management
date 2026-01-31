class Course < ApplicationRecord
  has_many :course_teachers, dependent: :destroy
  has_many :teachers, through: :course_teachers, source: :user

  has_many :enrolled_students, dependent: :destroy

   accepts_nested_attributes_for :course_teachers, allow_destroy: true, reject_if: :all_blank

  validates :code, presence: true
  validates :name, presence: true
  validates :year, presence: true
  validates :semester, presence: true
end

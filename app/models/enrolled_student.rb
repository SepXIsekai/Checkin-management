class EnrolledStudent < ApplicationRecord
  belongs_to :course

  validates :student_id, presence: true
  validates :student_id, uniqueness: { scope: :course_id }
end

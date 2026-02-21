class Attendance < ApplicationRecord
  belongs_to :checkin_form
  has_one_attached :photo
  validates :student_id, presence: true
  validates :name, presence: true
  validates :photo, presence: true
  validates :student_id, uniqueness: { scope: :checkin_form_id, message: "เช็คชื่อไปแล้ว" }

  before_create :set_checked_at

  private

  def set_checked_at
    self.checked_at ||= Time.current
  end
end

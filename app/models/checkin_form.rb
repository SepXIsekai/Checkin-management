# app/models/checkin_form.rb
class CheckinForm < ApplicationRecord
  belongs_to :course
  has_many :attendances, dependent: :destroy

  validates :title, presence: true
  validates :qr_token, presence: true, uniqueness: true

  before_validation :generate_qr_token, on: :create

  scope :active, -> { where(active: true) }

  def expired?
    expires_at.present? && Time.current > expires_at
  end

  def open?
    active? && !expired?
  end

  def token_expired?
    token_expires_at.present? && Time.current > token_expires_at
  end

  def refresh_token!
    update(
      qr_token: SecureRandom.urlsafe_base64(16),
      token_expires_at: 30.seconds.from_now
    )
  end

  def checkin_url(host = "localhost:3000")
    protocol = host.include?("ngrok") ? "https" : "http"
    "#{protocol}://#{host}/checkin/#{qr_token}"
  end

  def qr_code_svg(host = "localhost:3000")
    qrcode = RQRCode::QRCode.new(checkin_url(host))
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 8,
      standalone: true,
      use_path: true
    )
  end

  private

  def generate_qr_token
    self.qr_token ||= SecureRandom.urlsafe_base64(16)
    self.token_expires_at ||= 30.seconds.from_now
  end
end

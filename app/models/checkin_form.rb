# app/models/checkin_form.rb
class CheckinForm < ApplicationRecord
  belongs_to :course
  has_many :attendances, dependent: :destroy

  enum :mode, { online: 0, onsite: 1 }

  validates :title, presence: true
  validates :qr_token, presence: true, uniqueness: true
  validates :latitude, presence: true, if: :onsite?
  validates :longitude, presence: true, if: :onsite?

  before_validation :generate_qr_token, on: :create

  scope :active, -> { where(active: true) }

  def open?
    active?
  end

  def token_expired?
    token_expires_at.nil? || Time.current > token_expires_at
  end

  def refresh_token!
    update(
      qr_token: SecureRandom.urlsafe_base64(16),
      token_expires_at: 10.seconds.from_now
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

  def within_radius?(user_lat, user_lng)
    return true if online?
    return false if latitude.nil? || longitude.nil?

    distance = haversine_distance(latitude, longitude, user_lat, user_lng)
    distance <= (radius || 100)
  end

  private

  def generate_qr_token
    self.qr_token ||= SecureRandom.urlsafe_base64(16)
    self.token_expires_at ||= 30.seconds.from_now
  end

  def haversine_distance(lat1, lng1, lat2, lng2)
    rad_per_deg = Math::PI / 180
    earth_radius = 6371000 # meters

    dlat = (lat2 - lat1) * rad_per_deg
    dlng = (lng2 - lng1) * rad_per_deg

    a = Math.sin(dlat / 2)**2 + Math.cos(lat1 * rad_per_deg) * Math.cos(lat2 * rad_per_deg) * Math.sin(dlng / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    earth_radius * c
  end
end

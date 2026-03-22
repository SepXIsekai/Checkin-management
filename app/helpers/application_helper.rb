module ApplicationHelper
  def format_datetime(datetime)
    return "-" if datetime.blank?
    datetime.strftime("%d %b %Y • %H:%M")
  end

  def format_date(date)
    return "-" if date.blank?
    date.strftime("%d %B %Y")
  end

  def cloudinary_image_url(attachment)
    return nil unless attachment.attached?

    "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{attachment.blob.key}"
  end
end

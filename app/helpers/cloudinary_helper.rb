# app/helpers/cloudinary_helper.rb
module CloudinaryHelper
  def cloudinary_url(attachment)
    return nil unless attachment.attached?

    if Rails.env.production?
      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{attachment.key}"
    else
      rails_blob_url(attachment, disposition: "inline")
    end
  end
end

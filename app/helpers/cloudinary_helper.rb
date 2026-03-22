# app/helpers/cloudinary_helper.rb
module CloudinaryHelper
  def cloudinary_url(attachment)
    return nil unless attachment.attached?

    if Rails.env.production?
      cloud_name = ENV["CLOUDINARY_CLOUD_NAME"]
      "https://res.cloudinary.com/#{cloud_name}/image/upload/#{attachment.blob.key}"
    else
      url_for(attachment)
    end
  end
end

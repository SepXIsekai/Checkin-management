class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :student_id, :role, :secret_code ])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || if resource.teacher?
      courses_path
                                     else
      root_path
                                     end
  end

  private

  def storable_location?
    request.get? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end

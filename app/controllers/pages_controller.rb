class PagesController < ApplicationController
  def home
    if user_signed_in? && current_user.teacher?
      redirect_to courses_path
    end
  end
end

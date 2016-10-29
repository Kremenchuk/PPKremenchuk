class WelcomeController < ApplicationController
  def index
    #Выдача админских прав юзеру
      #@user = User.where("email = 'kremenchuk@bk.ru'").first
      #@user.admin = 1
      #@user.save

    button_const
  end

  def set_locale
    I18n.locale = params[:new_locale]
    session[:locale] = I18n.locale
    url_hash = Rails.application.routes.recognize_path URI(request.referer).path
    url_hash[:locale] = params[:new_locale]
    redirect_to url_hash
  end
end

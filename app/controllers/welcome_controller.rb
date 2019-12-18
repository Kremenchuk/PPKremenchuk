class WelcomeController < ApplicationController
  def index
    #Выдача админских прав юзеру
      #@user = User.where("email = 'kremenchuk@bk.ru'").first
      #@user.admin = 1
      #@user.save

    button_const
  end

  def about_us
  end

  def sitemap
    respond_to do |format|
      format.xml { render file: 'public/sitemaps/sitemap.xml' }
      format.html { redirect_to root_url }
    end
  end

  def robots

  end

end

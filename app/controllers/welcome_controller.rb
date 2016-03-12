class WelcomeController < ApplicationController
  def index
    #Выдача админских прав юзеру
      #@user = User.where("email = 'kremencuk@bk.ru'").first
      #@user.admin = 1
      #@user.save

    button_const
  end
end

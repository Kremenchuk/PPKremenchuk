class WelcomeController < ApplicationController
  def index
    #Выдача админских прав юзеру
      #@user = User.where("id = 3").first
      #@user.admin = 1
      #@user.save

    button_const
  end
end

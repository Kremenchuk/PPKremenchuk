class UsersController < ApplicationController
  before_action :check_if_admin
  before_action :find_user, only: [:show, :destroy, :update]

  attr_accessor :user

  def index
    @users = User.all
  end

  def show
  end

  def destroy
    return if current_user == user
    user.destroy!
    redirect_to users_path
  end

   def update
     user.update!(user_params)
     redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:admin, :diller)
  end

  def find_user
    @user = User.find(params[:id])
  end
end
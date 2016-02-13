class AdminPanelController < ApplicationController
  before_filter :check_if_admin, only: [:index]
  before_filter :find_user, only: [:change_diller, :destroy, :change_admin]

  def index
    @users = User.all
  end

  def change_diller
    @user.diller = !@user.diller
    @user.save!
    redirect_to action: "index"
  end

  def change_admin
    @user.admin = !@user.admin
    @user.save!
    redirect_to action: "index"
  end

  def destroy
    @user.destroy
    redirect_to action: "index"
  end



  private

  def find_user
    @user = User.where(id: params[:id]).first
    render_404 unless @user
  end
end
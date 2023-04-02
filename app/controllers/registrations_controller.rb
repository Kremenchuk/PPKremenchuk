class RegistrationsController < Devise::RegistrationsController
  protect_from_forgery with: :exception

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :login, :name)
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :login, :name)
  end
end
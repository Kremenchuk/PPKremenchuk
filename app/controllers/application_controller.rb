class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  before_action :configure_permitted_parameters, if: :devise_controller?


  def check_if_admin
    if authenticate_user!
      if current_user.admin?
      else
        render_403
      end
    end
  end

  def check_if_diller
    @constant = Constant.where("id = 1").first
    @diller_in = false
    #SendEmail.login_from_site(current_user.email).deliver_now
    if current_user != nil
      case current_user.diller
        when 4
          @natsenka = @constant.job_natsenka
        when 1
          @natsenka = @constant.job_natsen_diler
        when 2
          @natsenka = @constant.job_natsen_diler_second
        when 3
          @natsenka = @constant.job_natsen_diler_third
      else
        @natsenka = @constant.job_natsenka
      end
    end
  end


  def button_const
    @admin_in = false
    #SendEmail.login_from_site(current_user.email).deliver_now
    if current_user != nil
      if current_user.admin?
        @admin_in=true
      end
    end
  end


  def render_403 #Нет прав на просмотр данной страницы
    render file: "public/403.html.haml", status: 403
  end

  def render_404 #Нет страницы
    render file: "public/404.html", ststus: 404
  end


  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up)    {
        |u| u.permit(:email, :password, :password_confirmation, :login, :name)
    }
    devise_parameter_sanitizer.for(:account_update) {
        |u| u.permit(:email, :password, :password_confirmation, :current_password, :login, :name)
    }
  end
end

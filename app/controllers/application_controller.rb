class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  def check_if_admin
    if authenticate_user!
      if current_user.admin?
      else
        render_403
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

end

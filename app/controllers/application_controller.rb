class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  before_action :set_locale_a, :set_meta_tags, :set_contacts
  #

  def set_meta_tags
    @meta_tags = t("page.meta_tags.#{params[:controller]}", default: t('page.meta_tags.welcome'))
  end

  def set_locale
    I18n.locale = params[:new_locale]
    session[:locale] = I18n.locale
    url_hash = Rails.application.routes.recognize_path URI(request.referer).path
    url_hash[:locale] = params[:new_locale]
    url_hash = url_hash.merge(Rack::Utils.parse_query URI(request.referer).query)
    if current_user.present?
      current_user.language = params[:new_locale]
      current_user.save!
    end
    redirect_to url_hash
  end

  def default_url_options
    { locale: I18n.locale }
  end

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
      end
    else
      @natsenka = @constant.job_natsenka
    end
  end


  def button_const
    @admin_in = false
    #SendEmail.login_from_site(current_user.email).deliver_now
    if current_user != nil
      if current_user.admin?
        @admin_in = true
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

  def set_contacts
    @contacts = Contact.all
  end

  def set_locale_a
    I18n.locale = params[:locale] || (current_user.language.to_sym if current_user.present?) ||I18n.default_locale
    session[:locale] = I18n.locale
  end
end

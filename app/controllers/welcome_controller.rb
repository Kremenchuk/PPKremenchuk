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

  # Обробка контактної форми (секція 06) — надсилає email через SendEmail
  def contact_request
    name    = params[:name].to_s.strip
    phone   = params[:phone].to_s.strip
    message = params[:msg].to_s.strip

    if name.blank? || phone.blank?
      render json: { ok: false, error: 'invalid' }, status: :unprocessable_entity
      return
    end

    SendEmail.send_request(name, phone, message).deliver_now
    render json: { ok: true }
  rescue => e
    Rails.logger.error("contact_request failed: #{e.class} #{e.message}")
    render json: { ok: false, error: 'server' }, status: :internal_server_error
  end

  # def sitemap
  #   respond_to do |format|
  #     format.xml { render file: 'public/sitemaps/sitemap.xml' }
  #     format.html { redirect_to root_url }
  #   end
  # end

  def site_map

  end

  # def robots
  #
  # end

end

class SendEmail < ActionMailer::Base
  #default from: 'info@my.site'#, template_path: 'mailers/items'
  default from: 'fop.kremenchuk@gmail.com'

  def login_from_site(user_login)
    @user_login=user_login
    mail to: "kremenchuk@bk.ru",
        subject: "Вход на сайт #{@user_login}"
  end

  def send_calculation_file
    attachments['1.xlsx'] = File.read('1.xlsx')
    mail(to: "#{constant.email_to_send}", subject: "Файл с расчетами по сайту")
  end

  # Заявка з контактної форми на головній сторінці
  def send_request(name, phone, message)
    @name    = name.to_s.strip
    @phone   = phone.to_s.strip
    @message = message.to_s.strip

    recipient = constant&.email_to_send.presence || 'fop.kremenchuk@gmail.com'
    subject   = "Заявка з сайту STM Industry#{@name.present? ? " — #{@name}" : ''}"

    mail(to: recipient, subject: subject)
  end

  private

  def constant
    @constant ||= Constant.find(1)
  end
end

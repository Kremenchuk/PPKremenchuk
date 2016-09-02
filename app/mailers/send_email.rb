class SendEmail < ActionMailer::Base
  #default from: 'info@my.site'#, template_path: 'mailers/items'
  # default from: 'kremartem@gmail.com'

  def login_from_site(user_login)
    @constant = Constant.where("id = 1").first
    @user_login=user_login
    mail to: "kremenchuk@bk.ru",
        subject: "Вход на сайт #{@user_login}"
  end

  def send_calculation_file
    @constant = Constant.where("id = 1").first
    attachments['1.xlsx'] = File.read('1.xlsx')
    mail(to: "#{@constant.email_to_send}", subject: "Файл с расчетами по сайту")
  end
end

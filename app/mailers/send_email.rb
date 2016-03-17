class SendEmail < ApplicationMailer
  default from: 'kremartem@gmail.com'#, template_path: 'mailers/items'
  #default from: 'kremenchuka@ukr.net'

  def login_from_site(user_login)
    @constant = Constant.where("id = 1").first
    @user_login=user_login
    mail(to: "#{@constant.email_to_send}", subject: "Вход на сайт #{@user_login}")
  end

  def send_calculation_file
    @constant = Constant.where("id = 1").first
    attachments['2.xlsx'] = File.read('2.xlsx')
    mail(to: "#{@constant.email_to_send}", subject: "Файл с расчетами по сайту")
  end
end

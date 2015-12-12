class SendEmail < ApplicationMailer
  default from: 'kremartem@gmail.com'#, template_path: 'mailers/items'

  def login_from_site(user_login)
    @user_login=user_login
    mail(to: 'kremenchuk@bk.ru', subject: "Вход на сайт #{@user_login}")
  end
end

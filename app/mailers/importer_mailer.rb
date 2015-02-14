class ImporterMailer < ActionMailer::Base
  default from: "multilisting@multilisting.su"

  def finish(email)
    mail(to: email, subject: 'Загрузка адресата успешно выполена')
  end
end

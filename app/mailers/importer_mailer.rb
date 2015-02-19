class ImporterMailer < ActionMailer::Base
  default from: "multilisting@multilisting.su"

  def finish(email, body)
    @body = body
    mail(to: email, subject: 'Загрузка донрио успешно выполена')
  end
end

class RequestIcs < ActionMailer::Base
  default from: "padma@derosemethod.org"

  def first_day_of_month(school, email)
    ref_date = 1.month.ago.to_date
    @link = "https://statistics.padm.am/schools/#{school.id}/ics?ref_date=#{ref_date}"
    mail(
      to: email,
      reply_to: "dwayne.macgowan@derose-it-support.intercom-mail.com",
      subject: "Itens de controle para acompanhamento do Colegiado de Presidentes de Federação e Conselho Administrativo"
    )    
  end
end

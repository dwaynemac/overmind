class RequestIcs < ActionMailer::Base
  default from: "padma@derosemethod.org"

  def first_day_of_month(school, email)
    ref_date = 1.month.ago.to_date
    @link = "https://statistics.padm.am/schools/#{school.id}/ics?ref_date=#{ref_date}"
    mail(to: email,
      subject: "Indices de Controle -- Colegiado e Conselho"
    )    
  end
end

# encoding: utf-8
class MonthlyStat
  module MoneyStat

    def needs_unit?
      name.to_s.in?(%W(gross_income expenses profit))
    end

    def suggested_currency
      if @suggested_currency
        @suggested_currency
      else
        if school
          if school.account # padma account   
            @suggested_currency = case school.account.country
            when "Argentina"
              "ARS"
            when "Chile"
              "CLP"
            when "Brazil"
              "BRL"
            when "France", "Finland", "Portugal", "España", "United Kingdom", "Italy"
              "EUR"
            when "United States"
              "USD"
            when "Canada"
              "CAD"
            else
              "BRL"
            end
          end
        end
      end
    end
  end
end

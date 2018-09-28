/* global Stimulus */
/* global $ */
(() => {
  const application = Stimulus.Application.start();
  
  application.register("ics", class extends Stimulus.Controller {

    static get targets(){
      return ["gross_income","expenses","profit","profitError"];
    }
    
    initialize(){
      console.log("initialized ics");
    }

    updateProfit(){
      console.log("updating profit");
      var gross_income = parseInt(this.gross_incomeTarget.value);
      var expenses = parseInt(this.expensesTarget.value);
      this.profitTarget.value = gross_income - expenses;
      this.validateProfit()
    }
    
    validateProfit(){

      var gross_income = parseInt(this.gross_incomeTarget.value);
      var expenses = parseInt(this.expensesTarget.value);
      var profit = parseInt(this.profitTarget.value);

      if( (gross_income - expenses - profit) != 0 )
        this.setProfitError("check!!");
      else
        this.setProfitError("");

    }

    setProfitError(txt){
      if(txt != "")
        this.profitTarget.classList.add("ic_missing");
      else
        this.profitTarget.classList.remove("ic_missing");
      
      this.profitErrorTarget.innerText = txt;
    }

  });

})();

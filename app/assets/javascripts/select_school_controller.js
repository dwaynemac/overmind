/* global Stimulus */
/* global $ */
(() => {
  const application = Stimulus.Application.start();

  application.register("selectSchool", class extends Stimulus.Controller {

    static get targets(){
      return ["school"];
    }
    
    gotoSchoolIcs(){
      var school_id = this.schoolTarget.value;

      if( school_id ) {
        window.location.href = "/schools/"+school_id+"/ics?ref_date="+this.data.get("gotodate");
      } else {
        alert(this.data.get("select_school_msg"));
      }
    }
    
  });

})();

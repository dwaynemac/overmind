#
# //= require amcharts
# //= require charts/summary
# //= require best_in_place.tuned
#
$(document).ready ->

  $("#current_year").tooltip({placement: 'right'})
  $("#current_year").click ->
    $(this).hide()
    $(this).siblings("form").show()

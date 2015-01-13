#
# //= require amcharts
# //= require charts/summary
# //= require best_in_place.tuned
#
$(document).ready ->

  $("#current_year").tooltip({placement: 'right', trigger: 'hover manual'}).tooltip('show')
  $("#current_year").click ->
    $(this).hide()
    $(this).tooltip('hide')
    $(this).siblings("form").show()


  hideTooltip = () ->
    $("#current_year").tooltip('hide')

  setTimeout( hideTooltip, 5000 )

# //= require amcharts
# //= require charts/summary
# //= require charts/monitoreados
#
$(document).ready ->
  $("#current_year").tooltip({placement: 'right'})
  $("#current_year").click ->
    $(this).hide()
    $(this).siblings("form").show()

  $('.pictos.editable').click (e)->
    e.preventDefault()
    if $(this).siblings().length > 0
      $(this).parent().siblings('span').first().click()

#
# //= require amcharts
# //= require charts/summary
# //= require best_in_place.tuned
#
$(document).ready ->

  $("#current_year").tooltip({placement: 'right', trigger: 'hover manual'}).tooltip('show')
  $("#current_year").click ->
    registerEvent('clicked-change-statistics-year')
    $(this).hide()
    $(this).tooltip('hide')
    $(this).siblings("form").show()

  $(".choose-columns-select").multiselect
    buttonClass: 'btn btn-info btn-sm'
    enableCaseInsensitiveFiltering: true
    buttonText: (options, select) ->
      select.context.dataset.noneSelectedText

  hideTooltip = () ->
    $("#current_year").tooltip('hide')

  setTimeout( hideTooltip, 15000 )

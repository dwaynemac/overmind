$(document).ready ->
  $("#statsteacher-table").tablesorter()
  $('.btn input:checked').parent('.btn').button('toggle')
  $("#statsteacher-table td span").tooltip()

  $(".choose-columns-select").multiselect
    buttonClass: 'btn btn-info btn-sm'
    enableCaseInsensitiveFiltering: true
    buttonText: (options, select) ->
      select.context.dataset.noneSelectedText
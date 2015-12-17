$(document).ready ->
  $("#ranking_table").tablesorter()
  $('.btn input:checked').parent('.btn').button('toggle')
  $("#ranking_table td span").tooltip()

  $(".choose-columns-select").multiselect
    buttonClass: 'btn btn-info btn-sm'
    enableCaseInsensitiveFiltering: true
    buttonText: (options, select) ->
      select.context.dataset.noneSelectedText
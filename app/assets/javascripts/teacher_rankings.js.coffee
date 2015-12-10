$(document).ready ->
  $("#statsteacher-table").tablesorter()
  $('.btn input:checked').parent('.btn').button('toggle')
  $("#statsteacher-table td span").tooltip()

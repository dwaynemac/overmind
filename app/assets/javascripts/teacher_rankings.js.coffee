$(document).ready ->
  $("#ranking_table").tablesorter()
  $('.btn input:checked').parent('.btn').button('toggle')
  $("#ranking_table td span").tooltip()

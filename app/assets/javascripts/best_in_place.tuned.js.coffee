$(document).ready ->
  $('.best_in_place').on 'ajax:success', (event, data) ->
    $(this).removeClass("editable")
    $(this).attr("data-url", $(this).attr("data-url")+"/"+data.id)
    $(this).attr("data-method", "put")
  
  $('.best_in_place').on 'keydown', 'input', (e) ->
    keyCode = e.keyCode || e.which

    if (keyCode == 9)
      e.preventDefault()
      nextCell = $(this).parents('td').next().children('span')
      if nextCell.length == 0
        nextCell = $(this).parents('tr').next().children('td').first().children('span')
      $(this).parent().submit()
      nextCell.click()

  $('.best_in_place').tooltip()
  $(".best_in_place").best_in_place()

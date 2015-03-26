$(document).ready ->
  $('td').on 'ajax:success','.best_in_place', (event, data) ->
    $(this).removeClass("editable")
    $(this).closest('td').effect('highlight')
    $(this).attr("data-url", $(this).attr("data-url")+"/"+data.id)
    $(this).attr("data-method", "put")
  
  $('td').on 'ajax:error','.best_in_place', (event, data) ->
    $(this).closest('td').effect('highlight', {color: '#FF0000'})

  $('td').on 'keydown', '.best_in_place','input', (e) ->
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

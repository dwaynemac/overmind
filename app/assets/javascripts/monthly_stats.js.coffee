# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  $("#current_year").tooltip({placement: 'right'})
  $("#current_year").click ->
    $(this).hide()
    $(this).siblings("form").show()
  
  $('.best_in_place').on 'ajax:success', (event, data) ->
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

  $('span.best_in_place').each ->
    el = $(this)
    attrs = el.data('html-attrs')
    el.attr('tabindex', attrs['tabindex']) if attrs and attrs['tabindex']
  .focus ->
    el = $(this)
    el.click()

  $('.best_in_place').tooltip()

  $('.pictos.editable').click (e)->
    e.preventDefault()
    if $(this).siblings().length > 0
      $(this).parent().siblings('span').first().click()
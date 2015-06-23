# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# //= require charts/chart
# //= require charts/amcharts
# //= require charts/serial
# //= require charts/bar-chart
# //= require charts/pie-chart

$(document).ready ->

  $(".previ").click ->
    registerEvent("clicked-prev-in-month-summary")

  $("#slider-range").slider
    animate: "fast"
    value: $("#amount").val()
    min: 0
    max: 500
    slide: (event, ui) ->
      $("#amount").val ui.value
      return
  
    
  

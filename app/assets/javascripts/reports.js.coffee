# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# //= require charts/chart
# //= require charts/amcharts
# //= require charts/serial
# //= require charts/bar-chart
# //= require charts/pie-chart

$(document).ready ->
  $("#slider-range").slider
    range: true
    min: 0
    max: 500
    values: [
        75
        300
      ]
    slide: (event, ui) ->
      $("#amount").val "$" + ui.values[0] + " - $" + ui.values[1]
      return

  $("#amount").val "$" + $("#slider-range").slider("values", 0) + " - $" + $("#slider-range").slider("values", 1)
  
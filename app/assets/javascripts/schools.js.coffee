# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->

  $("#current_year").tooltip({placement: 'right'})
  $("#current_year").click ->
    $(this).hide()
    $(this).siblings("form").show()

  chart = new AmCharts.AmSerialChart()
  chart.dataProvider = chartData
  chart.categoryField = "month"

  chart.color = "#AAAAAA"
  chart.startDuration = 2
  chart.autoMargins = false;
  chart.marginTop = 30
  chart.marginBottom = 30;
  chart.marginLeft = 80
  chart.marginRight = 80

  students_graph = new AmCharts.AmGraph()
  students_graph.valueField = "students"
  students_graph.title = $("#stats-names").data(students_graph.valueField)
  students_graph.type = "line"
  students_graph.lineColor = "#3a81ec"
  students_graph.lineThickness = 2
  students_graph.bullet = "round"
  students_graph.dashLength = 1
  chart.addGraph(students_graph)

  p_interviews_graph = new AmCharts.AmGraph()
  p_interviews_graph.valueField = "p_interviews"
  p_interviews_graph.title = $("#stats-names").data(p_interviews_graph.valueField)
  p_interviews_graph.type = "column"
  p_interviews_graph.fillAlphas = 0.5;
  p_interviews_graph.lineColor = "yellow"
  p_interviews_graph.lineThickness = 1
  p_interviews_graph.dashLength = 1
  chart.addGraph(p_interviews_graph)

  enrollments_graph = new AmCharts.AmGraph()
  enrollments_graph.valueField = "enrollments"
  enrollments_graph.title = $("#stats-names").data(enrollments_graph.valueField)
  enrollments_graph.type = "column"
  enrollments_graph.fillAlphas = 0.5;
  enrollments_graph.lineColor = "green"
  enrollments_graph.lineThickness = 1
  enrollments_graph.dashLength = 1
  chart.addGraph(enrollments_graph)

  dropouts_graph = new AmCharts.AmGraph()
  dropouts_graph.valueField = "dropouts"
  dropouts_graph.title = $("#stats-names").data(dropouts_graph.valueField)
  dropouts_graph.type = "column"
  dropouts_graph.fillAlphas = 0.5;
  dropouts_graph.lineColor = "red"
  dropouts_graph.lineThickness = 1
  dropouts_graph.dashLength = 1
  chart.addGraph(dropouts_graph)
  
  chartCursor = new AmCharts.ChartCursor()
  chart.addChartCursor( chartCursor )

  valAxis = new AmCharts.ValueAxis()
  valAxis.position = "left"
  valAxis.axisColor = "#2d66bb"
  valAxis.gridAlpha = 0
  valAxis.fillColor = "#2d66bb"
  valAxis.fillAlpha = 0.1
  valAxis.dashLength = 3
  chart.addValueAxis(valAxis)

  legend = new AmCharts.AmLegend()
  legend.align = "center"
  legend.markerType = "circle"
  chart.addLegend(legend)

  chart.write('chartContainer')
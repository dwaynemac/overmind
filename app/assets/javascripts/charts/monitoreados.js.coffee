#
# needs amcharts
#
$(document).ready ->

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

  chartCursor = new AmCharts.ChartCursor()
  chart.addChartCursor( chartCursor )

  valAxis = new AmCharts.ValueAxis()
  valAxis.stackType = "regular";
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

  for degree in ['assistant_students', 'professor_students', 'master_students']
    graph = new AmCharts.AmGraph()
    graph.valueField = degree
    graph.title = $("#stats-names").data(degree)
    graph.type = "column"

    switch degree
      when 'assistant_students' then graph.lineColor = '#8BE4FF'
      when 'professor_students' then graph.lineColor = '#3B40FF'
      when 'master_students' then graph.lineColor = '#D303FF'

    graph.lineThickness = 1
    graph.fillAlphas = 0.7
    graph.dashLength = 1
    chart.addGraph(graph)

  chart.write('teachersChartContainer')

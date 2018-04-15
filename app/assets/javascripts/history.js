//= require amcharts
/* global $ */
/* global AmCharts */
/* global historyChartData */

$(document).ready(function(){
  
  var chart = new AmCharts.AmSerialChart();
  chart.dataProvider = historyChartData;
  chart.categoryField = "month";
  
  chart.color = "#AAAAAA";
  chart.startDuration = 2;
  chart.autoMargins = false;
  chart.marginTop = 30;
  chart.marginBottom = 30;
  chart.marginLeft = 80;
  chart.marginRight = 80;
  
  var chartCursor = new AmCharts.ChartCursor();
  chart.addChartCursor( chartCursor );

  var valAxis = new AmCharts.ValueAxis();
  valAxis.position = "left";
  valAxis.axisColor = "#2d66bb";
  valAxis.gridAlpha = 0;
  valAxis.fillColor = "#2d66bb";
  valAxis.fillAlpha = 0.1;
  valAxis.dashLength = 3;
  chart.addValueAxis(valAxis);
  
  var line = new AmCharts.AmGraph();
  line.valueField = "data";
  line.title = "Data";
  line.type = "line";
  line.lineColor = "black";
  line.lineThickness = 3;
  line.lineThickness = 3;
  line.bullet = "round";
  line.dashLength = 1;
  line.valueAxis = valAxis;
  chart.addGraph(line);

/*
  var legend = new AmCharts.AmLegend();
  legend.align = "center";
  legend.markerType = "circle";
  chart.addLegend(legend);
*/

  chart.write('historyChartContainer');  
  
});
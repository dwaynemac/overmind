var chart;

var pedagogic_chart_data = pedagogic_chart_data()
var pedagogic_chart_labels = pedagogic_chart_labels()

var chartData = [
    {
        "country": pedagogic_chart_labels["begginear"],
        "visits": pedagogic_chart_data["begginear"],
        "color": "#ebebeb"
    },
    {
        "country": pedagogic_chart_labels["sadhakas"],
        "visits": pedagogic_chart_data["sadhakas"],
        "color": "#e0dd6e"
    },
    {
        "country": pedagogic_chart_labels["yogins"],
        "visits": pedagogic_chart_data["yogins"],
        "color": "#f4b06d"
    },
    {
        "country": pedagogic_chart_labels["chelas"],
        "visits": pedagogic_chart_data["chelas"],
        "color": "#c44747"
    },
    {
        "country": pedagogic_chart_labels["graduate"],
        "visits": pedagogic_chart_data["graduate"],
        "color": "#ad74cc"
    },
    {
        "country": pedagogic_chart_labels["assistant"],
        "visits": pedagogic_chart_data["assistant"],
        "color": "#219cd9"
    },
    {
        "country": pedagogic_chart_labels["professor"],
        "visits": pedagogic_chart_data["professor"],
        "color": "#1671b8"
    },
	{
        "country": "",
        "visits": 0,
        "color": "#0000fe"
    }
];


AmCharts.ready(function () {
    // SERIAL CHART
    chart = new AmCharts.AmSerialChart();
    chart.dataProvider = chartData;
    chart.categoryField = "country";
    // the following two lines makes chart 3D
    //chart.depth3D = 20;
    //chart.angle = 30;

    // AXES
    // category
    var categoryAxis = chart.categoryAxis;
   // categoryAxis.labelRotation = 90;
    categoryAxis.dashLength = 2;
    categoryAxis.gridPosition = "start";

    // value
    var valueAxis = new AmCharts.ValueAxis();
    valueAxis.title = "";
    valueAxis.dashLength = 2;
    chart.addValueAxis(valueAxis);
    // GRAPH
    var graph = new AmCharts.AmGraph();
    graph.valueField = "visits";
    graph.colorField = "color";
    graph.balloonText = "<span style='font-size:14px'>[[category]]: <b>[[value]]</b></span>";
    graph.type = "column";
    graph.lineAlpha = 0;
    graph.fillAlphas = 1;
    chart.addGraph(graph);

    // CURSOR
    var chartCursor = new AmCharts.ChartCursor();
    chartCursor.cursorAlpha = 0;
    chartCursor.zoomable = false;
    chartCursor.categoryBalloonEnabled = false;
    chart.addChartCursor(chartCursor);

   // chart.creditsPosition = "top-right";


    // WRITE
    chart.write("chartdiv");
});

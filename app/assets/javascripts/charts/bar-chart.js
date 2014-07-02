var chart;

var pedagogic_chart_data = pedagogic_chart_data()

var chartData = [
    {
        "country": "begginear ",
        "visits": pedagogic_chart_data["begginear"],
        "color": "#cfd9db"
    },
    {
        "country": "sadhakas ",
        "visits": pedagogic_chart_data["sadhakas"],
        "color": "#fef400"
    },
    {
        "country": "yogins",
        "visits": pedagogic_chart_data["yogins"],
        "color": "#fe5e00"
    },
    {
        "country": "chelas",
        "visits": pedagogic_chart_data["chelas"],
        "color": "#ff060a"
    },
    {
        "country": "graduate",
        "visits": pedagogic_chart_data["graduate"],
        "color": "#9500d4"
    },
    {
        "country": "assistant teacher ",
        "visits": pedagogic_chart_data["assistant"],
        "color": "#01b1e1"
    },
    {
        "country": "professor (blue)",
        "visits": pedagogic_chart_data["professor"],
        "color": "#0000fe"
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

var chart;
            var chartData = [
                {
                    "country": "begginear ",
                    "visits": 850,
                    "color": "#cfd9db"
                },
                {
                    "country": "sadhakas ",
                    "visits": 490,
                    "color": "#fef400"
                },
                {
                    "country": "yogins",
                    "visits": 715,
                    "color": "#fe5e00"
                },
                {
                    "country": "chelas",
                    "visits": 450,
                    "color": "#ff060a"
                },
                {
                    "country": "graduate",
                    "visits": 1000,
                    "color": "#9500d4"
                },
                {
                    "country": "assistant teacher ",
                    "visits": 650,
                    "color": "#01b1e1"
                },
                {
                    "country": "professor (blue)",
                    "visits": 550,
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
			
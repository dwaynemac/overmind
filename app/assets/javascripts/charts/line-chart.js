var lineChartData = {
			labels : ["January","February","March","April","May","June","July"],
			datasets : [
				{
					fillColor : "rgba(169,132,198,0.6)",
					strokeColor : "rgba(169,132,198,1)",
					pointColor : "rgba(169,132,198,1)",
					pointStrokeColor : "#fff",
					data : [65,59,90,81,56,55,40]
				},
				{
					fillColor : "rgba(107,204,108,0.6)",
					strokeColor : "rgba(227,119,114,1)",
					pointColor : "rgba(227,119,114,1)",
					pointStrokeColor : "#fff",
					data : [60,18,10,85,20,88,50]
				},
				{
					fillColor : "rgba(107,204,180,0.6)",
					strokeColor : "rgba(107,204,180,1)",
					pointColor : "rgba(107,204,180,1)",
					pointStrokeColor : "#fff",
					data : [28,48,40,19,96,27,100]
				},
				{
					fillColor : "rgba(227,119,114,0.6)",
					strokeColor : "rgba(227,119,114,1)",
					pointColor : "rgba(227,119,114,1)",
					pointStrokeColor : "#fff",
					data : [10,48,10,19,36,87,100]
				}
				
			]
			
		}

	var myLine = new Chart(document.getElementById("canvas3").getContext("2d")).Line(lineChartData);
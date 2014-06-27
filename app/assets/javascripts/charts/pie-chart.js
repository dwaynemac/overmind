var doughnutData = [
				{
					value : 70,
					color : "#14b9d6"
				},
				{
					value: 30,
					color:"#e86741"
				}
			];
		var doughnutData2 = [
			
				{
					value : 50,
					color : "#14b9d6"
				},
				{
					value: 25,
					color:"#cfd9db"
				},
				{
					value : 25,
					color : "#9500d4"
				}
		];
	var myDoughnut = new Chart(document.getElementById("canvas").getContext("2d")).Doughnut(doughnutData);
	var myDoughnut = new Chart(document.getElementById("canvas2").getContext("2d")).Doughnut(doughnutData2);
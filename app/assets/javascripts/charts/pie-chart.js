var distributionData = distribution_pie_chart_data()
var studentsData = students_pie_chart_data()
var doughnutData = [
				{
					value : distributionData["male_students"],
					color : "#f4b06d"
				},
				{
					value: distributionData["female_students"],
					color:"#25a6dd"
				}
			];
var doughnutData2 = [
	  {
			value : studentsData["senior"],
			color : "#14b9d6"
		},
		{
			value: studentsData["begginer"],
			color:"#cfd9db"
		},
		{
			value : studentsData["graduate"],
			color : "#9500d4"
		}
  ];
	var myDoughnut = new Chart(document.getElementById("canvas").getContext("2d")).Doughnut(doughnutData);
	var myDoughnut = new Chart(document.getElementById("canvas2").getContext("2d")).Doughnut(doughnutData2);
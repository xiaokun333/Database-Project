
<head><title>Covid-19 Data</title></head>
<body>

<?php
include 'open.php';

//Override the PHP configuration file to display all errors
//This is useful during development but generally disabled before release
ini_set('error_reporting', E_ALL);
ini_set('display_errors', true);

//Collect the posted value in a variable called $item
//$item = $_POST['item'];
//array to store data
$dataPoints = array();
$next_yr = array();

echo "<h2>U.S. GDP Change in 2020 and 2021</h2>";
echo "Search State: ";


   //Prepare a statement that we can later execute. The ?'s are placeholders for
   //parameters whose values we will set before we run the query.
if ($stmt = $conn->prepare(
      "SELECT state, (2020Q1-2020Q4)/2020Q1*100 AS 2020gdpPercentChange, (2020Q4-2021Q3)/2020Q4*100 AS 2021gdpPercentChange ".
      "FROM State_gdp;")) {

      if ($stmt->execute()) {

         //Store result set generated by the prepared statement
         $result = $stmt->get_result();

         if (($result) && ($result->num_rows != 0)) {
	 
            //Create table to display results
            //echo "<table border=\"1px solid black\">";
            //echo "<tr><th> Year-Month-date </th> <th> Cumulative Cases </th> <th> Cumulative Deaths </th></tr>";

            //Report result set by visiting each row in it
            while ($row = $result->fetch_row()) {
               //echo "<tr>";
               //echo "<td>".$row[0]."</td>";
               //echo "<td>".$row[1]."</td>";
               //echo "<td>".$row[2]."</td>";
              // echo "</tr>";
               //push each row into our array
               array_push($dataPoints, array( "label"=> $row[0], "y"=> $row[1]));
               array_push($next_yr, array( "label"=> $row[0], "y"=> $row[2]));
            } 
           // print_r($c_death);
	 
            //echo "</table>";
            //store data into a 
            
         }	else {
         //if ($result->num_rows == 0) {
            //Result contains no rows at all
            echo "No state with the specified name";

		 }

         //We are done with the result set returned above, so free it
         $result->free_result();
      
      } else {

         //Call to execute failed, e.g. because server is no longer reachable,
	 //or because supplied values are of the wrong type
         echo "Execute failed.<br>";
      }
      echo "<br><br>";
     
      //Close down the prepared statement
      $stmt->close();

     
} else {

       //A problem occurred when preparing the statement; check for syntax errors
       //and misspelled attribute names in the statement string.
      echo "Prepare failed.<br>";
      $error = $conn->errno . ' ' . $conn->error;
      echo $error; 
}

//Close the connection created in open.php
$conn->close();
?>
</body>

<html>
<head>
<script>
window.onload = function () { 
	var chart1 = new CanvasJS.Chart("chartContainer1", {
		animationEnabled: true,
		exportEnabled: true,
		theme: "light1", // "light1", "light2", "dark1", "dark2"
		title:{
			text: "2020 GDP Percent Change"
		},
		data: [{
			type: "column", //change type to column, bar, line, area, pie, etc  
			dataPoints: <?php echo json_encode($dataPoints, JSON_NUMERIC_CHECK); ?>
		}]
	});
	chart1.render();
	var chart2 = new CanvasJS.Chart("chartContainer2", {
		animationEnabled: true,
		exportEnabled: true,
		theme: "light1", // "light1", "light2", "dark1", "dark2"
		title:{
			text: "2021 GDP Percent Change"		
                        },
		data: [{
			type: "column", //change type to column, bar, line, area, pie, etc  
			dataPoints: <?php echo json_encode($next_yr, JSON_NUMERIC_CHECK); ?>
		}]
	});
	chart2.render(); 
}
</script>
</head>
<body>
	<div id="chartContainer1" style="height: 400px; width: 100%;"></div>
	<br><br>
	<div id="chartContainer2" style="height: 400px; width: 100%;"></div>
	<script src="https://canvasjs.com/assets/script/canvasjs.min.js"></script>
</body>
</html>


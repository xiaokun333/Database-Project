
<head><title>PHP PreparedStatement example</title></head>
<body>

<?php

include 'open.php';

//Override the PHP configuration file to display all errors
//This is useful during development but generally disabled before release
ini_set('error_reporting', E_ALL);
ini_set('display_errors', true);

$dataPoints = array();


//Prepare a statement that we can later execute. The ?'s are placeholders for
//parameters whose values we will set before we run the query
if ($stmt = $conn->prepare(
      "SELECT name, administered65plus/administered AS rate ".
      "FROM States AS S LEFT OUTER JOIN State_vaccines AS V ON S.abv = V.location ".
      "WHERE date LIKE '04-10-2022' ".
      "ORDER BY rate DESC;")) {


   echo "<h2>Proportion of the Vaccination of 65 and Older by 04/10/2022 from Highest to Lowest</h2>";

   if ($stmt->execute()) {

      echo "Finding the administered vaccine count of 65 and older over total vaccine count for each state ... <br>";

      //Store result set generated by the prepared statement
      $result = $stmt->get_result();

      //Call function defined above to create html output
      //displayItems($result);

      while ($row = $result->fetch_row()) {
      	array_push($dataPoints, array( "y"=> $row[1], "label"=> $row[0]));
      }
      //print_r($dataPoints);
      //We are done with the result set returned above, so free it
      //before we try to call prepared statement again
      $result->free_result();
      
   } else {
      echo "First execute failed.<br>";
   }

   //Output some blank space
   echo "<br><br>";

   //Close down the prepared statement
   $stmt->close();

} else {

    //A problem occurred when preparing the statement; check for syntax errors
    //and misspelled attribute names in the statement string.
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
	
var chart = new CanvasJS.Chart("chartContainer", {
	animationEnabled: true,
	
	title:{
		text:"Proportion of 65 and Above Vaccination"
	},
	data: [{
		type: "column",
		name: "name",
		axisYType: "secondary",
		color: "#014D65",
		dataPoints: <?php echo json_encode($dataPoints, JSON_NUMERIC_CHECK); ?>	
	}]
	});
	chart.render();

}
</script>
</head>
<body>
	<div id="chartContainer" style="height: 370px; width: 100%;"></div>
	<script src="https://canvasjs.com/assets/script/canvasjs.min.js"></script>
</body>
</html>
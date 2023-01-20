<head><title>Insert New Data into dataset</title></head>
<body>

<?php
include 'open.php';

//Override the PHP configuration file to display all errors
//This is useful during development but generally disabled before release
ini_set('error_reporting', E_ALL);
ini_set('display_errors', true);

//Collect the posted value in a variable called $item
$country = $_POST['country'];
$date = $_POST['date'];
$sequenced = $_POST['sequenced'];
$variant = $_POST['variant'];


echo "<h2>Insert New Variant Data</h2>";

//Determine if any input was actually collected
if (empty($country)) {
  echo "No State Provided <br><br>";
} elseif (empty($date)) {
  echo "No Date Provided <br><br>";
} elseif (empty($sequenced)) {
  echo "No number sequenced Provided <br><br>";
} elseif (empty($variant)) {
  echo "No variant name Provided <br><br>";
} else {
  if ($stmt = $conn->prepare("CALL insertVarEU(?,?,?,?)")) {
     $stmt->bind_param("ssis",$country,$date,$sequenced,$variant);
     if($stmt->execute()) {
       $result = $stmt->get_result();
       if (($result) && ($result->num_rows != 0)) {
	 
            //Create table to display results
            echo "<table border=\"1px solid black\">";
            echo "<tr><th> result: </th></tr>";

            //Report result set by visiting each row in it
            while ($row = $result->fetch_row()) {
               echo "<tr>";
               echo "<td>".$row[0]."</td>";
               echo "</tr>";
            }
	 
            echo "</table>";
            
         } else {
            //Result contains no rows at all
            echo "ERROR: Something went wrong";

	 }

         //We are done with the result set returned above, so free it
         $result->free_result();
	 } else {
	   echo "Execute failed.<br>";
	 }
       $stmt->close();
       } else {
       	 echo "Prepare failed.<br>";
	  $error = $conn->errno . ' ' . $conn->error;
      	  echo $error; 
   }
}
$conn->close();
?>
</body>
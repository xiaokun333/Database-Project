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

echo "<h2>Delete State Cases</h2>";

//Determine if any input was actually collected
if (empty($country)) {
  echo "No Country Provided <br><br>";
} elseif (empty($date)) {
  echo "No Date Provided <br><br>";
} else {
  if ($stmt = $conn->prepare("DELETE FROM Euro_variant  WHERE country = ? AND year_week = ?")) {
     $stmt->bind_param("ss",$country,$date);
     if($stmt->execute()) {
     	   echo "Successfully Deleted!<br>";
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
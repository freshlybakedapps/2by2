<?
include 'parse.php';
$originalImageSize = 640;
$outputImageSize = 500;

if (isset($_GET['size'])) {
	$outputImageSize = $_GET['size'];
}


$holder = imagecreatetruecolor($outputImageSize, $outputImageSize);


$filter = "";
$value = "";

//Get the photos
$parse = new parseQuery($class = 'Photo');

if (isset($_GET['filter'])) {
    $filterParam = $_GET['filter'];
    $f = explode("|", $filterParam);
    $filter = $f[0];
    $value = $f[1];

    if($filter == "featured"){
    	$parse->whereEqualTo('featured', true);
    }else if($filter == "userId"){
    	$parse->wherePointer("user","_User",$value);//SREzPjOawD
    }else if($filter == "username"){
    	$parseUser = new parseQuery($class = 'users');
		$parseUser->whereEqualTo('username', $value);
		$result = $parseUser->find();
		$objectId = $result->results[0]->objectId;

		$parse->wherePointer("user","_User",$objectId);
    }else{
    	$parse->whereEqualTo($filter, $value);
    }
}



$parse->whereEqualTo('state', "full");
$parse->orderByDescending("createdAt");

$count = $parse->getCount()->count;

if (isset($_GET['limit'])) {
	$limit = min($count,$_GET['limit']);
	$n = floor(sqrt($limit));
	$parse->setLimit($n*$n);
}else{
	$n = floor(sqrt($count));
	$parse->setLimit($n*$n);
}

$result = $parse->find();
//Set up dynamic grid
$space=2;
$gridW=$outputImageSize;
$column=ceil(sqrt(count($result->results)));
$scale=(($gridW-($space*($column-1)))/$column);
//loop thur all photos		
for ($i=0; $i < count($result->results); $i++) { 
	if($i <= $column-1){
		$x=((($scale+$space)*$i));
		$y=0;
	}else{
		$x=((($scale+$space)*($i-(floor($i/$column))*$column)));
		$y=((($scale+$space)*(floor($i/$column))));
	}
	$url = $result->results[$i]->image_full->url;

	$src = imagecreatefromjpeg($url);
	imagecopyresized($holder, $src, $x, $y, 0, 0, $scale, $scale,$originalImageSize,$originalImageSize);
	imagedestroy($src);	
}

ob_start();
imagejpeg($holder);
$buffer = ob_get_clean();
ob_end_clean();
$base64 = base64_encode($buffer);

$file = new ParseFile('image/jpeg',$base64);
$fileSave = $file->save('c.jpg');

$fileSave->__type = 'File';
$object = new parseObject($class='Grid');

if($filter == "featured"){
    $object->__set('featured',true);	
}else if($filter == "userId"){
    $object->__set('userId',$value);	
}else if($filter == "username"){
	$object->__set('username',$value);
}

if (isset($_GET['limit'])) {
	$object->__set('limit',$_GET['limit']);
}
$object->__set('image64',$base64);
//$object->__set('image',$fileSave);
$object->save();


header('Content-Type: image/jpeg');
imagejpeg($holder);

?>
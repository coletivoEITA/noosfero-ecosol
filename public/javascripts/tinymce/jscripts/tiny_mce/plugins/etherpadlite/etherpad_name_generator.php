<?php
	$num = intval(file_get_contents('counter.txt'));
	$num++;
	$f = fopen('counter.txt','w');
	fwrite($f,$num);
	fclose($f);
	echo $_GET['padPrefix'].$num;
?>

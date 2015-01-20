<?php
header("Content-Type: text/html; charset=UTF-8");

$ddsversion = "1.3.1Pa";

global $ddsversion;

function pagemenu() {
	echo '<a href="index.php">메인</a> <a href="userlist.php">유저 목록</a> <a href="logdata.php">데이터 로그</a> <a href="logchat.php">채팅 로그</a> <a href="logout.php">로그아웃</a>';
}

function alert($content) {
	echo '<script>alert("'.$content.'");</script>';
}

function pagemove($urlpath) {
	echo '<script>document.location.href="'.$urlpath.'"</script>';
}

function pageback() {
	echo '<script>history.back();</script>';
}

function pagefoot() {
	echo '<i>Copyright (c) 2012-2013 Eakgnarok All Rights Reserved. <br>(Homepage: http://eakgnarok.pe.kr)</i>';
}

?>
<?php
header("Content-Type: text/html; charset=UTF-8");

include_once "includes/base.php";
include_once "session.php";
include_once "cnt.php";

$auth_name = $_SESSION["user_name"];

$prctype = $_POST['type'];

if ($prctype == 'login') {
	$usrid = $_POST['userid'];
	$usrpass = $_POST['userpass'];
	
	if (($usrid == $adm_id) && ($usrpass == $adm_pass)) {
		$_SESSION["user_name"] = $usrid;
		pagemove('index.php');
	} else {
		alert('아이디가 없거나 비밀번호가 틀렸습니다.');
		pageback();
	}
}
else if ($prctype == 'ubmodify') {
	$userbid = $_POST['umid'];
	$sendset = "SELECT * FROM dds_userbasic WHERE id='".$userbid."'";
	$q = mysql_query($sendset);
	$qrow = mysql_fetch_array($q);
	if ($qrow[ingame] == "0") {
		$userbnick = $_POST['umnick'];
		$userbauthid = $_POST['umauthid'];
		$userbmoney = $_POST['ummoney'];
		$userbclass = $_POST['umclass'];
		$userbfreetag = $_POST['umfreetag'];

		if ($userbmoney < 0)	$userbmoney = 0;
		if (($userbclass < 0) || ($userbclass > 4))	$userbclass = 0;

		$sendset = "UPDATE dds_userbasic SET nickname='$userbnick', authid='$userbauthid', money='$userbmoney', class='$userbclass', freetag='$userbfreetag' WHERE id='$userbid'";
		$q = mysql_query($sendset);
		if (!mysql_error()) {
			alert('성공적으로 수정되었습니다.');
			pagemove('userlist.php');
		}
	} else {
		alert('현재 유저가 접속해있기 때문에 수정할 수 없습니다!');
		pageback();
	}
}

?>
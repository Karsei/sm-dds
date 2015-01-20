<?php
include_once "includes/base.php";
include_once "session.php";

$cfgfile = "configs.php";
if (file_exists($cfgfile)) {
	include $cfgfile;
	
	if ($constat == 0)
		pagemove('./install/install.php');
}

$auth_name = $_SESSION["user_name"];
?>
<!DOCTYPE html>
<html lang="ko">

<head>

<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<title>Dynamic Dollar Shop Web Panel :: 메인</title>

<link rel="stylesheet" href="css/bootstrap.css">
<style type="text/css">
	#container p, h1, div {
		font-family: 나눔고딕, nanum gothic, 맑은고딕, malgun gothic, 돋음, dotum, arial, sans-serif;
	}
</style>
<script type="text/javascript" src="includes/js/base.js" charset="UTF-8"></script>
</head>

<body>

<div class="container" align="center">
	<div class="row">
		<div class="page-header">
			<p><h2><b>~ Dynamic Dollar Shop 관리자 페이지 ~</b></h2></p>
<? if (isset($auth_name)): ?>
			<? pagemenu(); ?>
<? endif; ?>
			
			
			<!--[if lt IE 9]>
			<font color="red">
			<p><b> ~ 이 메세지는 IE 8 이하의 버전을 이용하는 사용자들에게만 보입니다 ~ </b></p>
			<p>IE 8 이하의 버전은 지원하지 않으므로 비정상적으로 처리될 수 있습니다.</b><br>IE 9 이상의 버전을 이용하시거나 크롬 또는 파이어폭스 등을 이용하시는 것을 권장합니다.</font></p>
			<![endif]-->
		</div>
		
<? if (isset($auth_name)): ?>
		<p>안녕하세요, <b><? echo $auth_name; ?></b> 님!</p>
		<p>본 관리자 페이지에서는 여러 로그를 살펴보실 수 있습니다!</p>
		<p><b>'유저 목록'</b>: 서버에 들어온 유저들의 목록을 봅니다.<br><b>'데이터 로그'</b>: 서버에서 유저들이 데이터와 관련하여 이용한 로그를 봅니다.<br><b>'채팅 로그'</b>: 서버에서 유저들이 주고 받은 채팅 로그를 봅니다.</p>
		<p>&nbsp;</p>
<? else: ?>
		<p>안녕하세요! 본 웹 패널을 이용하시려면 로그인을 하셔야 이용하실 수 있습니다.</p>
		<form class="well" name="form_login" method="post" action="process.php" onSubmit="return Frm_Check1(this);">
			<table>
				<tr>
					<td style="text-align:right;"><b>아이디 : </b></td>
					<td><input type="text" name="userid" class="span3" placeholder="아이디 입력"></td>
				</tr>
				<tr>
					<td style="text-align:right;"><b>비밀번호 : </b></td>
					<td><input type="password" name="userpass" class="span3" placeholder="비밀번호 입력"></td>
				</tr>
			</table>
			<p><input type="hidden" name="type" value="login"><br><input class="btn" type="submit" name="Submit" value="로그인"></p>
		</form>
<? endif; ?>
		<div class="bottom">
			<table style="border:0px;width:100%;">
				<tr>
					<td><? pagefoot(); ?></td>
					<td><p style="text-align:right;"><b>v<? echo $ddsversion; ?></b></p><td>
				</tr>
			</table>
		</div>
	</div>
</div>

</body>

</html>
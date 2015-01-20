<?php
include_once "../includes/base.php";

$curstep = $_POST['instype'];
$seterror = 0;

if ($curstep == "4")
{
	@mysql_connect($_POST['inshost'], $_POST['insdauser'], $_POST['insdapass']);
	@mysql_select_db($_POST['insdaname']);
	
	if (!mysql_error())
	{
		$sqlfile = implode("", file("./install.sql")); 
		
		$f = explode(";", $sqlfile);
		for ($i = 0; $i < count($f); $i++) {
			if (trim($f[$i]) == "")	continue;
			
			mysql_query($f[$i]);
		}
		
		$cfgfile = "../configs.php";
		if (file_exists($cfgfile)) {
			$cfg_fp = fopen($cfgfile, "w+");
			fwrite($cfg_fp, "<? \$constat=1; \$db_host=\"".$_POST['inshost']."\"; \$db_database=\"".$_POST['insdaname']."\"; \$db_user=\"".$_POST['insdauser']."\"; \$db_pass=\"".$_POST['insdapass']."\"; \$adm_id=\"admin\"; \$adm_pass=\"123456\"; ?>");
			fclose($cfg_fp);
		}
		else
		{
			$seterror = 1;
		}
	}
	else
	{
		$seterror = 1;
	}
}
else if ($curstep == "6")
{
	pagemove('../index.php');
}

?>
<!DOCTYPE html>
<html lang="ko">

<head>

<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<title>Dynamic Dollar Shop Web Panel :: 설치</title>

<link rel="stylesheet" href="../css/bootstrap.css">
<style type="text/css">
	#container p, h1, div {
		font-family: 나눔고딕, nanum gothic, 맑은고딕, malgun gothic, 돋음, dotum, arial, sans-serif;
	}
</style>
</head>

<body>

<div class="container" align="center">
	<div class="row">
		<div class="page-header">
			<p><h2><b>~ Dynamic Dollar Shop 설치 페이지 ~</b></h2></p>
			
			
			<!--[if lt IE 9]>
			<font color="red">
			<p><b> ~ 이 메세지는 IE 8 이하의 버전을 이용하는 사용자들에게만 보입니다 ~ </b></p>
			<p>IE 8 이하의 버전은 지원하지 않으므로 비정상적으로 처리될 수 있습니다.</b><br>IE 9 이상의 버전을 이용하시거나 크롬 또는 파이어폭스 등을 이용하시는 것을 권장합니다.</font></p>
			<![endif]-->
		</div>
		
<? if (($curstep == "1") || ($curstep == "")): ?>
		<p> - <b>1 설치 준비</b> > 2 설치 환경 확인 > 3 설치 정보 입력 > 4 설치 > 5 설치 완료 - </p>
<? elseif ($curstep == "2"): ?>
		<p> - 1 설치 준비 > <b>2 설치 환경 확인</b> > 3 설치 정보 입력 > 4 설치 > 5 설치 완료 - </p>
<? elseif ($curstep == "3"): ?>
		<p> - 1 설치 준비 > 2 설치 환경 확인 > <b>3 설치 정보 입력</b> > 4 설치 > 5 설치 완료 - </p>
<? elseif ($curstep == "4"): ?>
		<p> - 1 설치 준비 > 2 설치 환경 확인 > 3 설치 정보 입력 > <b>4 설치</b> > 5 설치 완료 - </p>
<? elseif ($curstep == "5"): ?>
		<p> - 1 설치 준비 > 2 설치 환경 확인 > 3 설치 정보 입력 > 4 설치 > <b>5 설치 완료</b> - </p>
<? endif; ?>
<? if (($curstep == "1") || ($curstep == "")): ?>
		<form class="well" name="form_install" method="post" action="install.php">
			<p>&nbsp;</p>
			<p>Dynamic Dollar Shop 을 설치할 것입니다.</p>
			<p>아래에 있는 버튼을 눌러 설치를 진행하시기 바랍니다.</p>
			
			<p><input type="hidden" name="instype" value="2"><br><input class="btn" type="submit" name="Submit" value="다음"></p>
		</form>
<? elseif ($curstep == "2"): ?>
		<form class="well" name="form_install" method="post" action="install.php">
			<p>&nbsp;</p>
			<p> # DDS 웹 패널 폴더 퍼미션 확인: <?
			$okset = 0;
			$updirchk = substr(sprintf('%o', fileperms('..')), -3);
			
			if (($updirchk == "707") || ($updirchk == "777"))
			{
				echo '<b><font color="green">확인 완료</font></b>';
				$okset++;
			}
			else
			{
				echo '<b><font color="red">DDS 웹 패널 폴더의 권한을 707 또는 777로 변경하세요. (현재: '.$updirchk.')</font></b>';
			}
			 ?></p>
			<p> # 'configs.php' 파일 퍼미션 확인: <?
			$updirchk = substr(sprintf('%o', fileperms('../configs.php')), -3);
			
			if (($updirchk == "707") || ($updirchk == "777") || ($updirchk == "666"))
			{
				echo '<b><font color="green">확인 완료</font></b>';
				$okset++;
			}
			else
			{
				echo '<b><font color="red">\'configs.php\' 파일의 권한을 707 또는 777, 666로 변경하세요. (현재: '.$updirchk.')</font></b>';
			}
			 ?></p>
			<p>&nbsp;</p>
			<p>아래에 있는 버튼을 눌러 설치를 진행하시기 바랍니다.</p>
			<?
			if ($okset == 2)
			{
				echo '<p><input type="hidden" name="instype" value="3"><br>';
				echo '<input class="btn" type="submit" name="Submit" value="다음">';
			}
			else
			{
				echo "<p><b>위의 모든 충족 조건이 만족되지 않아 진행할 수 없습니다!</b></p>";
				echo '<p><input type="hidden" name="instype" value="3"><br>';
				echo '<input class="btn" type="submit" name="Submit" value="다음" disabled>';
			}
			?></p>
		</form>
<? elseif ($curstep == "3"): ?>
		<form class="well" name="form_install" method="post" action="install.php">
			<p>&nbsp;</p>
			<table>
				<tr>
					<td style="text-align:right;"><b>호스트 계정 : </b></td>
					<td><input type="text" name="inshost" class="span3" placeholder="호스트 입력(예: localhost)" value="localhost"></td>
				</tr>
				<tr>
					<td style="text-align:right;"><b>데이터베이스 이름 : </b></td>
					<td><input type="text" name="insdaname" class="span3" placeholder="데이터베이스 이름 입력" value=""></td>
				</tr>
				<tr>
					<td style="text-align:right;"><b>데이터베이스 유저 : </b></td>
					<td><input type="text" name="insdauser" class="span3" placeholder="데이터베이스 유저 입력" value=""></td>
				</tr>
				<tr>
					<td style="text-align:right;"><b>데이터베이스 비밀번호 : </b></td>
					<td><input type="password" name="insdapass" class="span3" placeholder="데이터베이스 비밀번호 입력" value=""></td>
				</tr>
			</table>
			
			<p><input type="hidden" name="instype" value="4"><br><input class="btn" type="submit" name="Submit" value="다음"></p>
		</form>
<? elseif ($curstep == "4"): ?>
		<form class="well" name="form_install" method="post" action="install.php">
			<p>&nbsp;</p>
			<?
			if ($seterror == 0)
			{
				echo "<b>데이터베이스가 성공적으로 설치되었습니다.</b>\n";
				echo '<p><input type="hidden" name="instype" value="5"><br><input class="btn" type="submit" name="Submit" value="다음"></p>';
			}
			else
			{
				echo '<font color="red"><b>설치를 하는 도중 오류가 발생하였습니다.</b></font>';
				echo '<p><input type="hidden" name="instype" value="3"><br><input class="btn" type="submit" name="Submit" value="뒤로"></p>';
			}
			
			?></p>
		</form>
<? elseif ($curstep == "5"): ?>
		<form class="well" name="form_install" method="post" action="install.php">
			<p>&nbsp;</p>
			<p>설치가 최종적으로 완료되었습니다.</p>
			<p>아래의 '메인' 버튼을 누르면 메인 화면으로 들어갑니다.</p>
			<p><input type="hidden" name="instype" value="6"><br><input class="btn btn-primary" type="submit" name="Submit" value="메인"></p>
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
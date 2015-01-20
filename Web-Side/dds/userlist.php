<?php
include_once "includes/base.php";
include_once "session.php";
include_once "cnt.php";

// 세션 획득
$auth_name = $_SESSION["user_name"];

// WHERE 추가 관련 함수
$num_where = 0;
$res_where = "";
function setWhere($swStr)
{
	global $num_where, $res_where;
	
	if ($num_where == 0)	$res_where = " WHERE ".$swStr." ";
	else if ($num_where > 0)	$res_where = $res_where."AND ".$swStr." ";
	
	$num_where++;
}

// 페이지 파라메터 추가 관련 함수
$num_pset = 0;
$pset = "";
function setPageParam($ppStr)
{
	global $num_pset, $pset;
	
	$pset = $pset.$ppStr;
	
	$num_pset++;
}

$getshowm = $_GET['pm'];

if (($getshowm == "") || ($getshowm == "0"))
{
	// 페이지 관련 설정
	$pagenum = $_GET['p'];
	if (!isset($pagenum))
		$pagenum = 1;

	$showlistnum = 30;
	$startset = ($pagenum - 1) * $showlistnum;

	// 검색 관련 설정
	$searchm = $_GET['scm'];
	$searchq = $_GET['scq'];
	if (isset($searchm) && ($searchm > 0)) {
		setPageParam("&scm=".$searchm);
		setPageParam("&scq=".$searchq);

		if ($searchm == 1) {
			setWhere("id LIKE '%".$searchq."%'");
		} else if ($searchm == 2) {
			setWhere("nickname LIKE '%".$searchq."%'");
		} else if ($searchm == 3) {
			setWhere("authid LIKE '%".$searchq."%'");
		} else if ($searchm == 4) {
			setWhere("freetag LIKE '%".$searchq."%'");
		}
	}

	// 쿼리 전송
	$sendset = "SELECT * FROM dds_userbasic".$res_where." ORDER BY id ASC LIMIT ".$startset.", ".$showlistnum;
	$q = mysql_query($sendset);
}
else if ($getshowm == "1")
{
	setWhere("id='".$_GET['pmid']."'");
	$sendset = "SELECT * FROM dds_userbasic".$res_where;
	$q = mysql_query($sendset);
	$qrow = mysql_fetch_array($q);
}

?>
<!DOCTYPE html>
<html lang="ko">

<head>

<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<title>Dynamic Dollar Shop Web Panel :: 유저 목록</title>

<link rel="stylesheet" href="css/bootstrap.css">
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
			<h2><b>~ Dynamic Dollar Shop 관리자 페이지 ~</b></h2>
			<p><b>~ User List PAGE (유저 목록 페이지) ~</b></p>
			<? pagemenu(); ?>
			
			<!--[if lt IE 9]>
			<font color="red">
			<p><b> ~ 이 메세지는 IE 8 이하의 버전을 이용하는 사용자들에게만 보입니다 ~ </b></p>
			<p>IE 8 이하의 버전은 지원하지 않으므로 비정상적으로 처리될 수 있습니다.</b><br>IE 9 이상의 버전을 이용하시거나 크롬 또는 파이어폭스 등을 이용하시는 것을 권장합니다.</font></p>
			<![endif]-->
		</div>
		
<? if (mysql_error()): ?>
		<div class="alert alert-error">
			<h4 class="alert-heading">오류 발생</h4>
			<? echo mysql_error(); ?>
		</div>
<? else: ?>
<? if (isset($auth_name)): ?>
<? if (($getshowm == "") || ($getshowm == "0")): ?>
<? if ($searchm > 0): ?>
		<div class="alert alert-success">
			<h4 class="alert-heading">결과 성공</h4>
			<?
			// 나중에 최적화
			$resultc = mysql_num_rows($q);
			if ($searchm == 1)	echo "'ID'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			else if ($searchm == 2)	echo "'닉네임'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			else if ($searchm == 3)	echo "'고유 번호'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			else if ($searchm == 4)	echo "'자유형 태그'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			?>
		</div>
<? endif; ?>
		<div class="span12">
			<div class="search" align="right">
				<div class="input-append">
					<form name="form-search" method="get" action="userlist.php">
						<select name="scm">
							<option value="0" selected>-선택-</option>
							<option value="1">ID</option>
							<option value="2">닉네임</option>
							<option value="3">고유 번호</option>
							<option value="4">자유형 태그</option>
						</select>
						<input type="text" id="appendedInputButtons" name="scq" class="input-medium search-query" placeholder="검색할 문자 입력"><button class="btn" type="submit">검색</button><? echo '<input type="hidden" name="p" value="'.$pagenum.'">'; ?>
					</form>
				</div>
			</div>

			<p><?
			$sendqc = "SELECT COUNT(*) AS cnt FROM dds_userbasic";
			$qc = mysql_query($sendqc);
			$totalcount = mysql_fetch_array($qc);
			$lastpage = (int)($totalcount[cnt] / $showlistnum) + 1;
			
			echo '<a href="./userlist.php?p=1'.$pset.'">처음</a> ';
			
			for ($i = 4; $i >= 1; $i--)
			{
				if (($pagenum - $i) > 0)
					echo '<a href="./userlist.php?p='.($pagenum-$i).$pset.'">'.($pagenum-$i).'</a> ';
			}
			
			echo '<a href="./userlist.php?p='.$pagenum.$pset.'"><b>'.$pagenum.'</b></a> ';
			
			for ($k = 1; $k <= 4; $k++)
			{
				if ($lastpage >= ($pagenum + $k))
					echo '<a href="./userlist.php?p='.($pagenum+$k).$pset.'">'.($pagenum+$k).'</a> ';
			}
			
			echo '<a href="./userlist.php?p='.$lastpage.$pset.'">끝</a>';
			?></p>
			
			<table class="table table-bordered table-striped">
				<thead>
					<tr class="textcenter">
						<td style="text-align:center;">ID</td>
						<td style="text-align:center;">닉네임</td>
						<td style="text-align:center;">고유 번호</td>
						<td style="text-align:center;">가입 일자</td>
						<td style="text-align:center;">금액</td>
						<td style="text-align:center;">등급</td>
						<td style="text-align:center;">자유형 태그</td>
						<td style="text-align:center;">접속 상태</td>
						<td style="text-align:center;width:25px;">기타</td>
					</tr>
				</thead>
				<tbody>
<? while ($qrow = mysql_fetch_array($q)): ?>
					<tr>
						<td style="text-align:center;"><? echo $qrow[id]; ?></td>
						<td style="text-align:center;"><? echo $qrow[nickname]; ?></td>
						<td style="text-align:center;"><? echo $qrow[authid]; ?></td>
						<td style="text-align:center;"><? echo $qrow[joindate]; ?></td>
						<td style="text-align:center;"><? echo $qrow[money]; ?></td>
						<td style="text-align:center;"><?
						if ($qrow['class'] == 0)
							echo '일반 유저';
						else if ($qrow['class'] == 1)
							echo '특별 유저';
						else if ($qrow['class'] == 2)
							echo 'VIP';
						else if ($qrow['class'] == 3)
							echo '관리자';
						else if ($qrow['class'] == 4)
							echo '최고 관리자';
						?></td>
						<td style="text-align:center;"><? echo $qrow[freetag]; ?></td>
						<td style="text-align:center;"><?
						if ($qrow[ingame] == 0)
							echo '<font color="red">X</font>';
						else if ($qrow[ingame] == 1)
							echo '<font color="green">O</font>';
						?></td>
						<td style="text-align:center;"><?
						if ($qrow[ingame] == 0)
							echo '<a href="./userlist.php?pm=1&pmid='.$qrow[id].'"><img src="./images/edit.png" title="수정" /></a>';
						?></td>
					</tr>
<? $count++; ?>
<? endwhile; ?>
				</tbody>
			</table>
<? if ($count == 0): ?>
			<p>등록된 유저가 없습니다.</p>
<? endif; ?>
			<?
			$sendqc = "SELECT COUNT(*) AS cnt FROM dds_userbasic";
			$qc = mysql_query($sendqc);
			$totalcount = mysql_fetch_array($qc);
			$lastpage = (int)($totalcount[cnt] / $showlistnum) + 1;
			
			echo '<a href="./userlist.php?p=1'.$pset.'">처음</a> ';
			
			for ($i = 4; $i >= 1; $i--)
			{
				if (($pagenum - $i) > 0)
					echo '<a href="./userlist.php?p='.($pagenum-$i).$pset.'">'.($pagenum-$i).'</a> ';
			}
			
			echo '<a href="./userlist.php?p='.$pagenum.$pset.'"><b>'.$pagenum.'</b></a> ';
			
			for ($k = 1; $k <= 4; $k++)
			{
				if ($lastpage >= ($pagenum + $k))
					echo '<a href="./userlist.php?p='.($pagenum+$k).$pset.'">'.($pagenum+$k).'</a> ';
			}
			
			echo '<a href="./userlist.php?p='.$lastpage.$pset.'">끝</a>';
			?>
		</div>
<? elseif ($getshowm == "1"): ?>
		<div class="span12">
			<p>유저 정보를 수정합니다.</p>
			<form class="well" name="form_umodify" method="post" action="process.php">
				<table class="table table-bordered table-striped" style="width:350px;">
					<tbody>
						<tr>
							<td style="text-align:right;width:100px;">닉네임 : </td>
							<td style="width:200px;"><? echo '<input type="text" name="umnick" class="span3" value="'.$qrow[nickname].'">'; ?></td>
						</tr>
						<tr>
							<td style="text-align:right;width:100px;">고유 번호 : </td>
							<td style="width:200px;"><? echo '<input type="text" name="umauthid" class="span3" value="'.$qrow[authid].'">'; ?></td>
						</tr>
						<tr>
							<td style="text-align:right;width:100px;">금액 : </td>
							<td style="width:200px;"><? echo '<input type="text" name="ummoney" class="span3" value="'.$qrow[money].'">'; ?></td>
						</tr>
						<tr>
							<td style="text-align:right;width:100px;">등급 : </td>
							<td style="width:200px;"><? echo '<input type="text" name="umclass" class="span3" value="'.$qrow['class'].'">'; ?></td>
						</tr>
						<tr>
							<td style="text-align:right;width:100px;">자유형 태그 : </td>
							<td style="width:200px;"><? echo '<input type="text" name="umfreetag" class="span3" value="'.$qrow[freetag].'">'; ?></td>
						</tr>
					</tbody>
				</table>
				<p><? echo '<input type="hidden" name="umid" value="'.$qrow[id].'">'; ?><input type="hidden" name="type" value="ubmodify"><br><input class="btn btn-warning" type="submit" name="Submit" value="수정"></p>
			</form>
		</div>
<? endif; ?>
<? else: ?>
<? pagemove("index.php"); ?>
<? endif; ?>
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
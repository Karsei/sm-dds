<?php
include_once "includes/base.php";
include_once "session.php";
include_once "cnt.php";

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

// 세션 획득
$auth_name = $_SESSION["user_name"];

// 페이지 관련
$page_num = $_GET['p'];
if (!isset($page_num))	$page_num = 1;

$showlistnum = 30;
$startset = ($page_num - 1) * $showlistnum;

/******* WHERE 설정 *******/
// AUTH 항목 기준
$authid = $_GET['aid'];
if (isset($authid))
{
	$authid = urldecode($authid);
	setWhere("authid='".$authid."'");
}

// PORT 항목 기준
$serverport = $_GET['port'];
if (isset($serverport))
{
	setWhere("svport=".$serverport);
}

// 검색 관련 설정
$searchm = $_GET['scm'];
$searchq = $_GET['scq'];
if (isset($searchm) && ($searchm > 0)) {
	setPageParam("&scm=".$searchm);
	setPageParam("&scq=".$searchq);

	if ($searchm == 1) {
		setWhere("id LIKE '%".$searchq."%'");
	} else if ($searchm == 2) {
		setWhere("svport LIKE '%".$searchq."%'");
	} else if ($searchm == 3) {
		setWhere("nickname LIKE '%".$searchq."%'");
	} else if ($searchm == 4) {
		setWhere("msg LIKE '%".$searchq."%'");
	} else if ($searchm == 5) {
		setWhere("authid LIKE '%".$searchq."%'");
	} else if ($searchm == 6) {
		setWhere("ip LIKE '%".$searchq."%'");
	}
}

/******* 파라메터 설정 *******/
// 파라메터 정리
if (isset($authid))	setPageParam("&aid=".urlencode($authid));
if (isset($serverport))	setPageParam("&port=".$serverport);

// 쿼리 전송
$sendset = "SELECT * FROM dds_serverchat".$res_where." ORDER BY id DESC LIMIT ".$startset.", ".$showlistnum;
$q = mysql_query($sendset);

// DEBUG
//echo "QUERY: ".$sendset."<br>RESWHERE: ".$res_where." [NUM: ".$num_where."]<br>PSET: ".$pset." [NUM: ".$num_pset."]";

?>
<!DOCTYPE html>
<html lang="ko">

<head>

<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<title>Dynamic Dollar Shop Web Panel :: 채팅 로그</title>

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
			<p><b>~ Chat Log PAGE (채팅 로그 페이지) ~</b></p>
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
<? if ($searchm > 0): ?>
		<div class="alert alert-success">
			<h4 class="alert-heading">결과 성공</h4>
			<?
			// 나중에 최적화
			$resultc = mysql_num_rows($q);
			if ($searchm == 1)	echo "'ID'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			else if ($searchm == 2)	echo "'포트'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			else if ($searchm == 3)	echo "'닉네임'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			else if ($searchm == 4)	echo "'내용'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			else if ($searchm == 5)	echo "'고유 번호'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			else if ($searchm == 6)	echo "'IP'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			?>
		</div>
<? endif; ?>
		<div class="span12">
			<div class="search" align="right">
				<div class="input-append">
					<form name="form-search" method="get" action="logchat.php">
						<select name="scm">
							<option value="0" selected>-선택-</option>
							<option value="1">ID</option>
							<option value="2">포트</option>
							<option value="3">닉네임</option>
							<option value="4">내용</option>
							<option value="5">고유 번호</option>
							<option value="6">IP</option>
						</select>
						<input type="text" id="appendedInputButtons" name="scq" class="input-medium search-query" placeholder="검색할 문자 입력"><button class="btn" type="submit">검색</button><? echo '<input type="hidden" name="p" value="'.$page_num.'">'; ?>
					</form>
				</div>
			</div>
			<p><?
			$sendqc = "SELECT COUNT(*) AS cnt FROM dds_serverchat".$res_where;
			$qc = mysql_query($sendqc);
			$totalcount = mysql_fetch_array($qc);
			$lastpage = (int)($totalcount[cnt] / $showlistnum) + 1;
			
			echo '<a href="./logchat.php?p=1'.$pset.'">처음</a> ';
			
			for ($i = 4; $i >= 1; $i--)
			{
				if (($page_num - $i) > 0)
					echo '<a href="./logchat.php?p='.($page_num-$i).$pset.'">'.($page_num-$i).'</a> ';
			}
			
			echo '<a href="./logchat.php?p='.$page_num.$pset.'"><b>'.$page_num.'</b></a> ';
			
			for ($k = 1; $k <= 4; $k++)
			{
				if ($lastpage >= ($page_num + $k))
					echo '<a href="./logchat.php?p='.($page_num+$k).$pset.'">'.($page_num+$k).'</a> ';
			}
			
			echo '<a href="./logchat.php?p='.$lastpage.$pset.'">끝</a>';
			?></p>
			
			<table class="table table-bordered table-striped">
				<thead>
					<tr class="textcenter">
						<td style="text-align:center;">ID</td>
						<td style="text-align:center;">날짜</td>
						<td style="text-align:center;">포트</td>
						<td style="text-align:center;">닉네임</td>
						<td style="text-align:center;">내용</td>
						<td style="text-align:center;">고유 번호</td>
						<td style="text-align:center;">IP</td>
					</tr>
				</thead>
				<tbody>
<? while ($qrow = mysql_fetch_array($q)): ?>
					<tr>
						<td style="text-align:center;"><? echo $qrow[id]; ?></td>
						<td style="text-align:center;"><? echo date("Y/m/d H:i:s", $qrow[date]); ?></td>
						<td style="text-align:center;"><? echo '<a href="./logchat.php?port='.$qrow[svport].'">'.$qrow[svport].'</a>'; ?></td>
						<td style="text-align:center;"><? echo $qrow[nickname]; ?></td>
						<td><? echo $qrow[msg]; ?></td>
						<td style="text-align:center;"><? echo '<a href="./logchat.php?aid='.urlencode($qrow[authid]).'">'.$qrow[authid].'</a>'; ?></td>
						<td style="text-align:center;"><? echo $qrow[ip]; ?></td>
					</tr>
<? $count++; ?>
<? endwhile; ?>
				</tbody>
			</table>
<? if ($count == 0): ?>
			<p>등록된 채팅 로그가 없습니다.</p>
<? endif; ?>
			<?
			$sendqc = "SELECT COUNT(*) AS cnt FROM dds_serverchat".$res_where;
			$qc = mysql_query($sendqc);
			$totalcount = mysql_fetch_array($qc);
			$lastpage = (int)($totalcount[cnt] / $showlistnum) + 1;
			
			echo '<a href="./logchat.php?p=1'.$pset.'">처음</a> ';
			
			for ($i = 4; $i >= 1; $i--)
			{
				if (($page_num - $i) > 0)
					echo '<a href="./logchat.php?p='.($page_num-$i).$pset.'">'.($page_num-$i).'</a> ';
			}
			
			echo '<a href="./logchat.php?p='.$page_num.$pset.'"><b>'.$page_num.'</b></a> ';
			
			for ($k = 1; $k <= 4; $k++)
			{
				if ($lastpage >= ($page_num + $k))
					echo '<a href="./logchat.php?p='.($page_num+$k).$pset.'">'.($page_num+$k).'</a> ';
			}
			
			echo '<a href="./logchat.php?p='.$lastpage.$pset.'">끝</a>';
			?>
		</div>
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
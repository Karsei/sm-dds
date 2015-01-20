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
	setWhere("clauthid='".$authid."'");
}

// PORT 항목 기준
$serverport = $_GET['port'];
if (isset($serverport))
{
	setWhere("svport=".$serverport);
}

// 행동 항목 기준
$page_mode = $_GET['m'];
if (isset($page_mode))
{
	if ($page_mode == 1)	setWhere("(action='1' OR action='2')");
	else if ($page_mode == 2)	setWhere("(action='3' OR action='4' OR action='5' OR action='7')");
	else if ($page_mode == 3)	setWhere("action='6'");
}

// 검색 관련 설정
$searchm = $_GET['scm'];
$searchq = $_GET['scq'];
if (isset($searchm) && ($searchm > 0)) {
	$pset = "&scm=".$searchm."&scq=".$searchq;

	if ($searchm == 1) {
		setWhere("id LIKE '%".$searchq."%'");
	} else if ($searchm == 2) {
		setWhere("svport LIKE '%".$searchq."%'");
	} else if ($searchm == 3) {
		setWhere("clnickname LIKE '%".$searchq."%' OR tanickname LIKE '%".$searchq."%'");
	} else if ($searchm == 4) {
		setWhere("clauthid LIKE '%".$searchq."%' OR taauthid LIKE '%".$searchq."%'");
	} else if ($searchm == 5) {
		setWhere("ip LIKE '%".$searchq."%'");
	}
}

/******* 파라메터 설정 *******/
// 파라메터 정리
if (isset($page_mode))	setPageParam("&m=".$page_mode);
if (isset($authid))	setPageParam("&aid=".urlencode($authid));
if (isset($serverport))	setPageParam("&port=".$serverport);

$itfieldnum = 0;

// 쿼리 전송
$sendset = "SELECT * FROM dds_serverlog".$res_where." ORDER BY id DESC LIMIT ".$startset.", ".$showlistnum;
$q = mysql_query($sendset);
$itfieldnum = mysql_num_fields($q) - 12;

// DEBUG
//echo "QUERY: ".$sendset."<br>RESWHERE: ".$res_where." [NUM: ".$num_where."]<br>PSET: ".$pset." [NUM: ".$num_pset."]";

?>
<!DOCTYPE html>
<html lang="ko">

<head>

<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<title>Dynamic Dollar Shop Web Panel :: 데이터 로그</title>

<link rel="stylesheet" href="css/bootstrap.css">
<style type="text/css">
	#container p, h1, div {
		font-family: 나눔고딕, nanum gothic, 맑은고딕, malgun gothic, 돋음, dotum, arial, sans-serif;
	}
</style>
<script type="text/javascript" src="./includes/js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="./includes/js/bootstrap.min.js"></script>
<script type="text/javascript" src="./includes/js/base.js"></script>
</head>

<body>

<div class="container" align="center">
	<div class="row">
		<div class="page-header">
			<h2><b>~ Dynamic Dollar Shop 관리자 페이지 ~</b></h2>
			<p><b>~ Data Log PAGE (데이터 로그 페이지) ~</b></p>
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
			else if ($searchm == 4)	echo "'고유 번호'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			else if ($searchm == 5)	echo "'IP'으로 '".$searchq."'을(를) 찾아 ".$resultc." 건의 결과를 얻었습니다.";
			?>
		</div>
<? endif; ?>
		<div class="span12">
			<p><a href="./logdata.php">[전체]</a>&nbsp;<a href="./logdata.php?m=1">[접속]</a>&nbsp;<a href="./logdata.php?m=2">[일반]</a>&nbsp;<a href="./logdata.php?m=3">[관리]</a></p>
			<div class="search" align="right">
				<div class="input-append">
					<form name="form-search" method="get" action="logdata.php">
						<select name="scm">
							<option value="0" selected>-선택-</option>
							<option value="1">ID</option>
							<option value="2">포트</option>
							<option value="3">닉네임</option>
							<option value="4">고유 번호</option>
							<option value="5">IP</option>
						</select>
						<input type="text" id="appendedInputButtons" name="scq" class="input-medium search-query" placeholder="검색할 문자 입력"><button class="btn" type="submit">검색</button><? echo '<input type="hidden" name="p" value="'.$page_num.'">'; ?>
					</form>
				</div>
			</div>
			<p><?
			$sendqc = "SELECT COUNT(*) AS cnt FROM dds_serverlog".$res_where;
			$qc = mysql_query($sendqc);
			$totalcount = mysql_fetch_array($qc);
			$lastpage = (int)($totalcount[cnt] / $showlistnum) + 1;
			
			echo '<a href="./logdata.php?p=1'.$pset.'">처음</a> ';
			
			for ($i = 4; $i >= 1; $i--)
			{
				if (($page_num - $i) > 0)
					echo '<a href="./logdata.php?p='.($page_num-$i).$pset.'">'.($page_num-$i).'</a> ';
			}
			
			echo '<a href="./logdata.php?p='.$page_num.$pset.'"><b>'.$page_num.'</b></a> ';
			
			for ($k = 1; $k <= 4; $k++)
			{
				if ($lastpage >= ($page_num + $k))
					echo '<a href="./logdata.php?p='.($page_num+$k).$pset.'">'.($page_num+$k).'</a> ';
			}
			
			echo '<a href="./logdata.php?p='.$lastpage.$pset.'">끝</a>';
			?></p>
			
			<table class="table table-bordered table-striped">
				<thead>
					<tr class="textcenter">
						<td style="text-align:center;">ID</td>
						<td style="text-align:center;">날짜</td>
						<td style="text-align:center;">포트</td>
						<td style="text-align:center;">행동</td>
						<td style="text-align:center;">내역</td>
						<td style="text-align:center;">IP</td>
						<td style="text-align:center;width:25px">정보</td>
					</tr>
				</thead>
				<tbody>
<? while ($qrow = mysql_fetch_array($q)): ?>
					<tr>
						<td style="text-align:center;"><? echo $qrow[id]; ?></td>
						<td style="text-align:center;"><? echo @date("Y/m/d H:i:s", $qrow[date]); ?></td>
						<td style="text-align:center;"><? echo '<a href="./logdata.php?port='.$qrow[svport].'">'.$qrow[svport].'</a>'; ?></td>
						<td style="text-align:center;"><?
						
						if ($qrow[action] == 1) {
							if (($qrow[subaction] == 1) || ($qrow[subaction] == 0)) {
								echo '~접속~';
							}
							else if ($qrow[subaction] == 3) {
								echo '게임 참여';
							}
						} else if ($qrow[action] == 2) {
							if (($qrow[subaction] == 2) || ($qrow[subaction] == 0)) {
								echo '~접속 해제~';
							}
							else if ($qrow[subaction] == 4) {
								echo '게임 퇴장';
							}
						} else if ($qrow[action] == 3) {
							echo '구매';
						} else if ($qrow[action] == 4) {
							echo '되팔기';
						} else if ($qrow[action] == 5) {
							echo '버리기';
						} else if ($qrow[action] == 6) {
							if ($qrow[subaction] == 1) {
								echo '관리 - 금액 주기';
							}
							else if ($qrow[subaction] == 2) {
								echo '관리 - 금액 뺏기';
							}
							else if ($qrow[subaction] == 3) {
								echo '관리 - 아이템 주기';
							}
							else if ($qrow[subaction] == 4) {
								echo '관리 - 아이템 뺏기';
							}
							else if ($qrow[subaction] == 5) {
								echo '관리 - 등급 조정';
							}
						} else if ($qrow[action] == 7) {
							if ($qrow[subaction] == 1) {
								echo '선물 - 금액';
							}
							else if ($qrow[subaction] == 2) {
								echo '선물 - 아이템';
							}
							else if ($qrow[subaction] == 3) {
								echo '선물 - 금액 예약';
							}
							else if ($qrow[subaction] == 4) {
								echo '선물 - 아이템 예약';
							}
						}
						
						?></td>
						<td><?
						
						if ($qrow[action] == 1) {
							if (($qrow[subaction] == 1) || ($qrow[subaction] == 0)) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 접속하였습니다.';
							}
							else if ($qrow[subaction] == 3) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 게임에 참여하였습니다.';
							}
						} else if ($qrow[action] == 2) {
							if (($qrow[subaction] == 2) || ($qrow[subaction] == 0)) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 접속 해제하였습니다.';
							}
							else if ($qrow[subaction] == 4) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 게임에서 퇴장하였습니다.';
							}
						} else if ($qrow[action] == 3) {
							echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[anydata1].'</b>을(를) 사서 <b>'.$qrow[anydata2].'</b>의 돈이 남았습니다.';
						} else if ($qrow[action] == 4) {
							echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[anydata1].'</b>을(를) 되팔아서 <b>'.$qrow[anydata2].'</b>의 돈이 남았습니다.';
						} else if ($qrow[action] == 5) {
							echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[anydata1].'</b>을(를) 버렸습니다.';
						} else if ($qrow[action] == 6) {
							if ($qrow[subaction] == 1) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[tanickname].'</b> 님('.$qrow[taauthid].')에게 <b>'.$qrow[anydata1].'</b>의 돈을 주어 <b>'.$qrow[anydata2].'</b>의 돈이 남았습니다.';
							}
							else if ($qrow[subaction] == 2) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[tanickname].'</b> 님('.$qrow[taauthid].')의 <b>'.$qrow[anydata1].'</b>의 돈을 빼앗아 <b>'.$qrow[anydata2].'</b>의 돈이 되었습니다.';
							}
							else if ($qrow[subaction] == 3) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[tanickname].'</b> 님('.$qrow[taauthid].')에게 <b>'.$qrow[anydata1].'</b>을(를) 주었습니다.';
							}
							else if ($qrow[subaction] == 4) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[tanickname].'</b> 님('.$qrow[taauthid].')의 <b>'.$qrow[anydata1].'</b>을(를) 회수하였습니다.';
							}
							else if ($qrow[subaction] == 5) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[tanickname].'</b> 님('.$qrow[taauthid].')에게 등급 <b>'.$qrow[anydata1].'</b>을(를) 주었습니다.';
							}
						} else if ($qrow[action] == 7) {
							if ($qrow[subaction] == 1) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[tanickname].'</b> 님('.$qrow[taauthid].')에게 <b>'.$qrow[anydata1].'</b>의 돈을 선물하였습니다.';
							}
							else if ($qrow[subaction] == 2) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 <b>'.$qrow[tanickname].'</b> 님('.$qrow[taauthid].')에게 <b>'.$qrow[anydata2].'</b> 개의 <b>'.$qrow[anydata1].'</b>을 주었습니다.';
							}
							else if ($qrow[subaction] == 3) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 예약 등록으로 인해 <b>'.$qrow[anydata1].'</b>의 돈을 받았습니다.';
							}
							else if ($qrow[subaction] == 4) {
								echo '<b>'.$qrow[clnickname].'</b> 님('.$qrow[clauthid].')이 예약 등록으로 인해 <b>'.$qrow[anydata2].'</b> 개의 <b>'.$qrow[anydata1].'</b>을 받았습니다.';
							}
						}
						
						?></td>
						<td style="text-align:center;"><? echo $qrow[ip]; ?></td>
						<td style="text-align:center;"><?
						
						$setinfostr = "";
						
						for ($u = 1; $u <= $itfieldnum; $u++)
						{
							$arrset = "";
							
							if ($u < 10)	$arrset = "L0".$u;
							else if ($u >= 10)	$arrset = "L".$u;
							
							if ($u == 1)	$setinfostr = $qrow["$arrset"];
							else if ($u > 1)	$setinfostr = $setinfostr.$qrow["$arrset"];
							
							if ($u != $itfieldnum)	$setinfostr = $setinfostr."^";
						}
						
						if (($qrow[action] > 2) || ((($qrow[action] == 1) || ($qrow[action] == 2)) && (($qrow[subaction] == 3) || ($qrow[subaction] == 4))))
							echo '<a href="#showinfo" data-toggle="modal" onclick="sendInfo('.$itfieldnum.', \''.$qrow[clnickname].'\', \''.$setinfostr.'\');"><img src="./images/info.png" /></a>';
						
						?></td>
					</tr>
<? $count++; ?>
<? endwhile; ?>
				</tbody>
			</table>
			
			<div id="showinfo" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="showinfoLabel" aria-hidden="true">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
					<h3 id="showinfoLabel">아이템 정보</h3>
				</div>
				<div class="modal-body">
					<div id="showinfo_sub" align="left">
					</div>
				</div>
				<div class="modal-footer">
					<button class="btn" data-dismiss="modal" aria-hidden="true">닫기</button>
				</div>
			</div>
<? if ($count == 0): ?>
			<p>등록된 데이터 로그가 없습니다.</p>
<? endif; ?>
			<?
			$sendqc = "SELECT COUNT(*) AS cnt FROM dds_serverlog".$res_where;
			$qc = mysql_query($sendqc);
			$totalcount = mysql_fetch_array($qc);
			$lastpage = (int)($totalcount[cnt] / $showlistnum) + 1;
			
			echo '<a href="./logdata.php?p=1'.$pset.'">처음</a> ';
			
			for ($i = 4; $i >= 1; $i--)
			{
				if (($page_num - $i) > 0)
					echo '<a href="./logdata.php?p='.($page_num-$i).$pset.'">'.($page_num-$i).'</a> ';
			}
			
			echo '<a href="./logdata.php?p='.$page_num.$pset.'"><b>'.$page_num.'</b></a> ';
			
			for ($k = 1; $k <= 4; $k++)
			{
				if ($lastpage >= ($page_num + $k))
					echo '<a href="./logdata.php?p='.($page_num+$k).$pset.'">'.($page_num+$k).'</a> ';
			}
			
			echo '<a href="./logdata.php?p='.$lastpage.$pset.'">끝</a>';
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
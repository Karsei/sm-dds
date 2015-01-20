<?php
header("Content-Type: text/html; charset=UTF-8");

include_once "includes/base.php";
include_once "session.php";

$_SESSION["user_name"] = '';
session_destroy();

alert("로그아웃 되었습니다.");
pagemove("index.php");
?>
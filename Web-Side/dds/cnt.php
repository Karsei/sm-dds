<?php
include_once "configs.php";

global $db_host, $db_database, $db_user, $db_pass, $adm_id, $adm_pass;

mysql_connect($db_host, $db_user, $db_pass);
mysql_select_db($db_database);
mysql_query('SET NAMES "UTF8"');
?>
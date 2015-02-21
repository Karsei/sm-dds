<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

function GetCodeByLanguage($code, $lower = true, $rev = true) {
	$data = array(
		"en" => "English",
		"ar" => "Arabic",
		"pt" => "Brazilian",
		"bg" => "Bulgarian",
		"cze" => "Czech",
		"da" => "Danish",
		"nl" => "Dutch",
		"fi" => "Finnish",
		"fr" => "French",
		"de" => "German",
		"el" => "Greek",
		"he" => "Hebrew",
		"hu" => "Hungarian",
		"it" => "Italian",
		"jp" => "Japanese",
		"ko" => "Korean",
		"lv" => "Latvian",
		"lt" => "Lithuanian",
		"no" => "Norwegian",
		"pl" => "Polish",
		"pt_p" => "Portuguese",
		"ro" => "Romanian",
		"ru" => "Russian",
		"chi" => "SChinese",
		"sk" => "Slovak",
		"es" => "Spanish",
		"sv" => "Swedish",
		"zho" => "TChinese",
		"th" => "Thai",
		"tr" => "Turkish",
		"ua" => "Ukrainian"
	);
	foreach ($data as $key => $val)
	{
		if (!$rev)
		{
			if (strcasecmp($key, $code) != 0)	continue;
			return $lower ? strtolower($val) : $val;
		}
		else
		{
			if (strcasecmp($val, $code) != 0)	continue;
			return $lower ? strtolower($key) : $key;
		}
	}
}

function SplitStrByGeoName($geo, $gloname)
{
	$lineCut = '||';
	$valueCut = ':';

	$geoidx = strpos($gloname, $geo);
	$endidx = strpos($gloname, $lineCut, $geoidx);
	$realData = '';
	if ($endidx === false)	$realData = substr($gloname, $geoidx);
	else	$realData = substr($gloname, $geoidx, $endidx);

	$val = explode($valueCut, $realData);

	return $val[1];
}

?>
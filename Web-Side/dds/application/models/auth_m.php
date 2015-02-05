<?php

class Auth_m extends CI_Model {
	
	function __construct()
	{
		parent::__construct();
	}

	function MakeSignin()
	{
		$rval = form_open('auth/login', '', array('gosign' => '1'));
		$rval .= '<p class="center">';
		$rval .= form_input(array('type' => 'image', 'src' => images_url() . 'login.png', 'maxlength' => '0', 'style' => 'width: 114px; height: 43px; text-align: center;'));
		$rval .= '</p>';
		$rval .= form_close();

		return $rval;
	}
}

?>
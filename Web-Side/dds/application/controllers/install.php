<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Install extends CI_Controller {

	function __construct()
	{
		parent::__construct();

		// 이미 설치가 되어 있다면 기본 페이지로 이동
		$this->load->helper('url');
		if (!file_exists(DDS_CONFIG_PATH))
		{
			index_page();
		}
	}

	public function index()
	{
		//
	}
}

?>
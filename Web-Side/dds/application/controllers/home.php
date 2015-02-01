<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Home extends CI_Controller {

	function __construct()
	{
		parent::__construct();

		// 설치가 되지 않은 경우 설치 페이지로 이동
		$this->load->helper('url');
		if (!file_exists(DDS_CONFIG_PATH . '/config.php'))
		{
			redirect('/install/');
		}

		// 로그인 여부
		/*$cSess = $this->session;
		if (!$cSess->userdata(''))*/
	}

	public function index()
	{
		$this->load->view('_top');
		$this->load->view('page_home');
		$this->load->view('_foot');
	}
}

?>
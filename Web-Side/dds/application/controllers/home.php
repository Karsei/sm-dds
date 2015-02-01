<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Home extends CI_Controller {

	function __construct()
	{
		parent::__construct();

		// 설치가 되지 않은 경우 설치 페이지로 이동
		$this->load->helper('url');
		if (!file_exists(CONFIG_PATH . '/config.php'))
		{
			redirect('/install/');
		}

		// 로그인 여부
		$this->load->library('session');
		$cSess = $this->session;
		
		if (!$cSess->userdata('auth_id')) {
			redirect('/login/');
		}

		// 메뉴 모듈 로드
		$this->load->model('menu_m');
	}

	public function index()
	{
		$tdata['menuset'] = $this->menu_m->CreateMenu('홈');
		$this->load->view('_top', $tdata);
		$this->load->view('page_home');
		$this->load->view('_foot');
	}
}

?>
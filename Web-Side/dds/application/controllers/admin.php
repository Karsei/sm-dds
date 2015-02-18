<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Admin extends CI_Controller {

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
			redirect('/auth/login');
		}

		// 메뉴 모델 로드
		$this->load->model('menu_m');
	}

	public function index()
	{
		// 기본 정보
		$tdata['title'] = '관리';
		$tdata['menuset'] = $this->menu_m->CreateMenu($tdata['title']);
		$pdata['icon'] = $this->menu_m->GetIcon($tdata['title']);
		$pdata['title'] = $tdata['title'];

		// 출력
		$this->load->view('_top', $tdata);
		$this->load->view('page_admin', $pdata);
		$this->load->view('_foot');
	}
}

?>
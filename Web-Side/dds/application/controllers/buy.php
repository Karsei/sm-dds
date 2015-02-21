<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Buy extends CI_Controller {

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

		// 언어 파일 로드
		$usrLang = $this->session->userdata('lang');

		// 유저 언어에 따른 언어 파일 로드
		$this->lang->load('menu', $usrLang);
		$this->lang->load('global', $usrLang);

		// 메뉴 모델 로드
		$this->load->model('menu_m');
		// 목록 모델 로드
		$this->load->model('list_m');
	}

	public function index()
	{
		// 기본 정보
		$tdata['title'] = $this->lang->line('menu_itembuy');
		$tdata['menuset'] = $this->menu_m->CreateMenu($tdata['title']);
		$pdata['icon'] = $this->menu_m->GetIcon($tdata['title']);
		$pdata['title'] = $tdata['title'];

		// 정보 등록
		$pdata['authid'] = $this->session->userdata('auth_id');
		$pdata['usrprf'] = $this->list_m->GetProfile($pdata['authid']);

		// 기타 정보 담기
		$pdata['langData'] = $this->lang;

		// 출력
		$this->load->view('_top', $tdata);
		$this->load->view('page_buy', $pdata);
		$this->load->view('_foot');
	}
}

?>
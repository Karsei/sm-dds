<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Auth extends CI_Controller {

	function __construct()
	{
		parent::__construct();

		// OpenID 로드
		$hostUrl = array('url' => base_url());
		$this->load->library('LightOpenID', $hostUrl);
		// 세션 로드
		$this->load->library('session');
		// 인증 모델 로드
		$this->load->model('auth_m');

		// 스팀 Web API는 OpenID 2.0을 사용하고 있으므로 라이브러리 로드
		$oid = $this->lightopenid;
		
		// 상황별 구분
		if (!$oid->mode)
		{
			if ($this->input->post('gosign') == '1') {
				// 증명 설정
				$oid->identity = 'http://steamcommunity.com/openid';
				// 인증 페이지로 고고
				header('Location: ' . $oid->authUrl());
			}
		}
		else if ($oid->mode == 'cancel')
		{
			redirect('/auth/login/');
		}
		else
		{
			if ($oid->validate())
			{
				preg_match("/^http:\/\/steamcommunity\.com\/openid\/id\/(7[0-9]{15,25}+)$/", $oid->identity, $stid);
				$this->session->set_userdata('auth_id', $stid[1]);
				redirect('/auth/login/');
			}
		}
	}

	public function index()
	{
		// 기본적으로 기본 화면으로 리다이렉트
		if ($this->session->userdata('auth_id')) {
			redirect('/home/');
		} else {
			redirect('/auth/login/');
		}
	}

	public function login()
	{
		// 로그인되어 있으면 기본 화면으로 리다이렉트
		if ($this->session->userdata('auth_id')) {
			redirect('/home/');
		}

		// 로그인 페이지
		$data['setform'] = $this->auth_m->MakeSignin();
		$this->load->view('page_login', $data);
	}

	public function logout()
	{
		// 세션 제거
		$usrdata = $this->session->all_userdata();
		foreach ($usrdata as $key => $value) {
			if ($key != 'session_id' && $key != 'ip_address' && $key != 'user_agent' && $key != 'last_activity') {
				$this->session->unset_userdata($key);
			}
		}
		redirect('/auth/login/', 'refresh');
	}
}

?>
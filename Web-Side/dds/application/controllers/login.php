<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Login extends CI_Controller {

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

		// 로그인되어 있으면 기본 화면으로 리다이렉트
		if ($this->session->userdata('auth_id')) {
			redirect('/home/');
		}

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
			var_dump("No");
		}
		else
		{
			if ($oid->validate())
			{
				preg_match("/^http:\/\/steamcommunity\.com\/openid\/id\/(7[0-9]{15,25}+)$/", $openid->identity, $stid);
				$this->session->set_userdata('auth_id', $stid[1]);
				redirect('/login/');
			}
		}
	}

	public function index()
	{
		$data['setform'] = $this->auth_m->MakeSignin();
		$this->load->view('page_login', $data);
	}
}

?>
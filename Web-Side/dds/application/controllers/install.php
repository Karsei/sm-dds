<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Install extends CI_Controller {

	function __construct()
	{
		parent::__construct();

		// 설치 모델 로드
		$this->load->model('install_m');

		// 이미 설치가 되어 있다면 기본 페이지로 이동
		if (!file_exists(DDS_CONFIG_PATH . '/config.php'))
		{
			index_page();
		}
	}

	public function index()
	{
		$stepIdx = 1;

		// 넘겨진 항목 설정
		if ($this->input->post('step', TRUE)) {
			$stepIdx = $this->input->post('step', TRUE);
		};

		// 정보 할당
		$data['step'] = 'Step ' . $this->install_m->GetStep($stepIdx);
		$data['stepdesc'] = $this->install_m->GetStepDesc($stepIdx);
		$data['insdesc'] = $this->install_m->GetStepInsDesc($stepIdx);

		$this->load->view('install/_top');
		$this->load->view('install/main', $data);
		$this->load->view('install/_foot');
	}

	public function get()
	{
		// 
	}
}

?>
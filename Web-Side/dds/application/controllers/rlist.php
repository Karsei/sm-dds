<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Rlist extends CI_Controller {

	function __construct()
	{
		parent::__construct();

		// 목록 모델 로드
		$this->load->model('list_m');
	}

	function getList()
	{
		$type = $this->input->post('t', TRUE);
		$data['type'] = $type;
		$data['list'] = $this->list_m->GetList($type, 0, 20);
		$this->load->view('ajax_list', $data);
	}

	function index()
	{
		echo 'Why do you enter here? :)';
	}
}

?>
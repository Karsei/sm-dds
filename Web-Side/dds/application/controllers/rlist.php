<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Rlist extends CI_Controller {

	function __construct()
	{
		parent::__construct();

		// 목록 모델 로드
		$this->load->model('list_m');

		// 세션 로드
		$this->load->library('session');

		// 언어 파일 로드
		$usrLang = $this->session->userdata('lang');

		// 유저 언어에 따른 언어 파일 로드
		$this->lang->load('global', $usrLang);
	}

	function getList()
	{	
		// 기본 정보 담기
		$data['authid'] = $this->session->userdata('auth_id');
		$data['usrLang'] = $this->session->userdata('lang');
		$data['surl'] = base_url();

		// 페이지 양쪽 번호 범위 갯수
		$pageSideCount = 4;
		// 페이지 당 레코드 갯수
		$pageRecords = 20;
		// 페이지
		$pageNum = 0;

		// 타입 분별
		$type = $this->input->post('t', TRUE);
		$cpage = $this->input->post('p', TRUE);
		$data['type'] = $type;

		// 페이지 조정
		if ($cpage == 0)	$cpage = 1; // 잡혀있지 않은 경우 번호 1로 세팅
		$data['pageIdx'] = $cpage; // 현재 페이지 번호
		if ($cpage > 0)	$cpage -= 1; // 페이지 당 레코드 갯수로 인해 1을 빼서 처리
		$pageNum += $cpage * $pageRecords;

		// 목록 추출
		$data['pageSideCount'] = $pageSideCount;
		$data['pageRecords'] = $pageRecords;
		$data['pageNum'] = $pageNum;
		$data['listCount'] = $this->list_m->GetList($type, $pageNum, $pageRecords, $data['authid'], true);
		$data['list'] = $this->list_m->GetList($type, $pageNum, $pageRecords, $data['authid'], false);

		// 전체 페이지 갯수 파악
		$data['pageTotal'] = ceil($data['listCount'] / $pageRecords);

		// 기타 정보 담기
		$data['langData'] = $this->lang;

		// 목록 출력
		$this->load->view('ajax_list', $data);
	}

	function doProcess()
	{
		// 기본 준비
		$authid = $this->session->userdata('auth_id');

		// 타입 분별
		$type = $this->input->post('t', TRUE);
		$itemidx = $this->input->post('idx', TRUE);
		$icidx = $this->input->post('icidx', TRUE);

		// 작업 처리
		$this->list_m->SetList($type, $icidx, $itemidx, $authid);
	}

	function index()
	{
		echo 'Why do you enter here? :)';
	}
}

?>
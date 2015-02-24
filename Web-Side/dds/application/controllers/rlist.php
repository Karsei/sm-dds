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
		/********************************************
		 * 기본 정보
		*********************************************/
		$data['authid'] = $this->session->userdata('auth_id');
		$data['usrLang'] = $this->session->userdata('lang');
		$data['surl'] = base_url();

		// POST 로드 및 언어 로드
		$type = $this->input->post('t', TRUE);
		$cpage = $this->input->post('p', TRUE);
		$data['type'] = $type;
		$data['langData'] = $this->lang;

		/********************************************
		 * 기타 필요 정보 삽입
		*********************************************/
		$data['usrprofile'] = $this->list_m->GetProfile($data['authid']);

		/********************************************
		 * 페이지 조정
		*********************************************/
		// 페이지 양쪽 번호 범위 갯수
		$pageSideCount = 4;
		// 페이지 당 레코드 갯수
		$pageRecords = 20;
		// 페이지
		$pageNum = 0;

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

		/********************************************
		 * 출력
		*********************************************/
		$this->load->view('ajax_list', $data);
	}

	function doProcess()
	{
		// 기본 준비
		$authid = $this->session->userdata('auth_id');

		// 타입 분별
		$type = $this->input->post('t', TRUE);
		$odata = $this->input->post('odata', TRUE);
		$tdata = $this->input->post('tdata', TRUE);

		// 작업 처리
		$rval = $this->list_m->SetList($type, $odata, $tdata, $authid);
		echo $rval;
	}

	function makeDetInfo()
	{
		// 타입 분별
		$type = $this->input->post('t', TRUE);
		$dat = $this->input->post('dat', TRUE);

		$rval = '';
		if (strcmp($type, 'itemlist-add') == 0)
		{
			$rval .= '<div class="box-title">';
			$rval .= '<h1>' . $this->lang->line('admin_itemlist_add') . '</h1>';
			$rval .= '</div>';
			/** 아이템 종류 코드 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_icidx') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			$rval .= '<input name="iladd-code" class="input-line x-short" type="text" maxlength="8" />';
			$rval .= '</div></div>';
			/** 아이템 이름 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_name') . '</label>';
			$rval .= '</div>';
			$rval .= '<div id="iladd-namesec" class="col-10">';
			$rval .= '<div class="addname" data-num="1">';
			$rval .= '<input name="iladd-langname" class="input-line xx-short" type="text" maxlength="2" placeholder="ko" value="ko" />';
			$rval .= '<input name="iladd-name" class="input-line short" type="text" maxlength="30" />';
			$rval .= '</div>';
			$rval .= '<p><button id="btn_langadd" name="iladd-langadd">' . $this->lang->line('btn_langadd') . '</button></p>';
			$rval .= '</div>';
			$rval .= '</div>';
			/** 아이템 금액 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_money') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			$rval .= '<input name="iladd-money" class="input-line x-short" type="text" maxlength="30" />';
			$rval .= '</div></div>';
			/** 아이템 지속 속성 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_havtime') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			$rval .= '<input name="iladd-havtime" class="input-line x-short" type="text" maxlength="15" />';
			$rval .= '</div>';
			$rval .= '</div>';
			/** 아이템 ENV **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_env') . '</label>';
			$rval .= '</div>';
			$rval .= '<div id="iladd-envsec" class="col-10">';
			$rval .= '<div class="addenv" data-num="1">';
			$rval .= '<input name="iladd-env" class="input-line short" type="text" maxlength="40" />';
			$rval .= '<input name="iladd-envvalue" class="input-line medium" type="text" maxlength="128" />';
			$rval .= '</div>';
			$rval .= '<p><button id="btn_envadd" name="iladd-envadd">' . $this->lang->line('btn_envadd') . '</button></p>';
			$rval .= '</div>';
			$rval .= '</div>';
			/** 아이템 활성화 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_status') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			$rval .= '<input name="iladd-status" type="radio" value="0" />' . $this->lang->line('admin_list_nouse') . '<input name="iladd-status" type="radio" value="1" checked />' . $this->lang->line('admin_list_use');
			$rval .= '</div>';
			$rval .= '</div>';
			$rval .= '<button id="btn_additem">' . $this->lang->line('btn_create') . '</button>';
		}
		else if (strcmp($type, 'itemcglist-add') == 0)
		{
			$rval .= '<div class="box-title">';
			$rval .= '<h1>' . $this->lang->line('admin_itemcglist_add') . '</h1>';
			$rval .= '</div>';
			/** 아이템 종류 이름 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_name') . '</label>';
			$rval .= '</div>';
			$rval .= '<div id="icadd-namesec" class="col-10">';
			$rval .= '<div class="addname" data-num="1">';
			$rval .= '<input name="icadd-langname" class="input-line xx-short" type="text" maxlength="2" placeholder="ko" value="ko" />';
			$rval .= '<input name="icadd-name" class="input-line short" type="text" maxlength="30" />';
			$rval .= '</div>';
			$rval .= '<p><button id="btn_langadd" name="icadd-langadd">' . $this->lang->line('btn_langadd') . '</button></p>';
			$rval .= '</div>';
			$rval .= '</div>';
			/** 아이템 종류 우선 순위 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_orderidx') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			$rval .= '<input name="icadd-orderidx" class="input-line x-short" type="text" maxlength="4" />';
			$rval .= '</div>';
			$rval .= '</div>';
			/** 아이템 종류 ENV **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_env') . '</label>';
			$rval .= '</div>';
			$rval .= '<div id="icadd-envsec" class="col-10">';
			$rval .= '<div class="addenv" data-num="1">';
			$rval .= '<input name="icadd-env" class="input-line short" type="text" maxlength="40" />';
			$rval .= '<input name="icadd-envvalue" class="input-line medium" type="text" maxlength="128" />';
			$rval .= '</div>';
			$rval .= '<p><button id="btn_envadd" name="icadd-envadd">' . $this->lang->line('btn_envadd') . '</button></p>';
			$rval .= '</div>';
			$rval .= '</div>';
			/** 아이템 종류 활성화 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_status') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			$rval .= '<input name="icadd-status" type="radio" value="0" />' . $this->lang->line('admin_list_nouse') . '<input name="icadd-status" type="radio" value="1" checked />' . $this->lang->line('admin_list_use');
			$rval .= '</div>';
			$rval .= '</div>';
			$rval .= '<button id="btn_additemcg">' . $this->lang->line('btn_create') . '</button>';
		}
		else if (strcmp($type, 'itemlist-modify') == 0)
		{
			$this->db->select('dds_item_list.icidx, dds_item_list.gloname, dds_item_list.money, dds_item_list.havtime, dds_item_list.env, dds_item_list.status');
			$this->db->where('dds_item_list.ilidx', $dat);
			$q = $this->db->get('dds_item_list');
			$qc = $q->result_array();

			$rval .= '<div class="box-title">';
			$rval .= '<h1>' . $this->lang->line('admin_itemlist_modify') . '</h1>';
			$rval .= '</div>';
			/** 아이템 종류 코드 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_icidx') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			$rval .= '<input name="iladd-code" class="input-line x-short" type="text" maxlength="8" value="' . $qc[0]['icidx'] . '" />';
			$rval .= '</div></div>';
			/** 아이템 이름 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_name') . '</label>';
			$rval .= '</div>';
			$rval .= '<div id="iladd-namesec" class="col-10">';
			$rval .= '<div class="addname" data-num="1">';
			$rval .= '<input name="iladd-langname" class="input-line xx-short" type="text" maxlength="2" placeholder="ko" value="ko" />';
			$rval .= '<input name="iladd-name" class="input-line short" type="text" maxlength="30" />';
			$rval .= '</div>';
			$rval .= '<p><button id="btn_langadd" name="iladd-langadd">' . $this->lang->line('btn_langadd') . '</button></p>';
			$rval .= '</div>';
			$rval .= '</div>';
			/** 아이템 금액 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_money') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			$rval .= '<input name="iladd-money" class="input-line x-short" type="text" maxlength="30" value="' . $qc[0]['money'] . '" />';
			$rval .= '</div></div>';
			/** 아이템 지속 속성 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_havtime') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			$rval .= '<input name="iladd-havtime" class="input-line x-short" type="text" maxlength="15" value="' . $qc[0]['havtime'] . '" />';
			$rval .= '</div>';
			$rval .= '</div>';
			/** 아이템 ENV **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_env') . '</label>';
			$rval .= '</div>';
			$rval .= '<div id="iladd-envsec" class="col-10">';
			$rval .= '<div class="addenv" data-num="1">';
			$rval .= '<input name="iladd-env" class="input-line short" type="text" maxlength="40" />';
			$rval .= '<input name="iladd-envvalue" class="input-line medium" type="text" maxlength="128" />';
			$rval .= '</div>';
			$rval .= '<p><button id="btn_envadd" name="iladd-envadd">' . $this->lang->line('btn_envadd') . '</button></p>';
			$rval .= '</div>';
			$rval .= '</div>';
			/** 아이템 활성화 **/
			$rval .= '<div class="form-section">';
			$rval .= '<div class="col-2">';
			$rval .= '<label class="label">' . $this->lang->line('tb_cate_status') . '</label>';
			$rval .= '</div>';
			$rval .= '<div class="col-10">';
			if (intval($qc[0]['status']) == 0) {
				$rval .= '<input name="iladd-status" type="radio" value="0" checked />' . $this->lang->line('admin_list_nouse') . '<input name="iladd-status" type="radio" value="1" />' . $this->lang->line('admin_list_use');
			}
			else {
				$rval .= '<input name="iladd-status" type="radio" value="0" />' . $this->lang->line('admin_list_nouse') . '<input name="iladd-status" type="radio" value="1" checked />' . $this->lang->line('admin_list_use');
			}
			$rval .= '</div>';
			$rval .= '</div>';
			$rval .= '<button id="btn_modifyitem">' . $this->lang->line('btn_create') . '</button>';
		}

		echo $rval;
	}

	function setDetInfo()
	{
		// 타입 분별
		$type = $this->input->post('dt', TRUE);
		$dat = $this->input->post('dat', TRUE);
		
		$rval = $this->list_m->SetDetInfo($type, $dat);
		echo $rval;
	}

	function index()
	{
		echo 'Why do you enter here? :)';
	}
}

?>
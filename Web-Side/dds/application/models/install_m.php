<?php

class Install_m extends CI_Model {

	function __construct()
	{
		parent::__construct();

		$this->load->helper('file');
	}

	function GetStepList($stepidx)
	{
		$stepList = array(
			array(1, '라이센스 확인'),
			array(2, '퍼미션 확인'),
			array(3, '설치 준비'),
			array(4, '설치'),
			array(5, '필요 정보 입력'),
			array(6, '완료'),
			array(7, '홈 이동')
		);
		return $stepList[$stepidx - 1];
	}

	function GetStep($stepidx)
	{
		return $this->GetStepList($stepidx)[0];
	}

	function GetStepDesc($stepidx)
	{
		return $this->GetStepList($stepidx)[1];
	}

	function GetStepInsDesc($stepidx)
	{
		/**
		 * stepList 에 따라 작성할 것
		 */
		$rval = '';
		switch ($stepidx)
		{
			case 1:
			{
				$attr = array('step' => '2');
				$rval .= form_open('install', '', $attr);
				$rval .= '<p>\'' . PRODUCT_NAME . '\'을 설치할 것입니다. 아래의 GPL v3 라이센스를 읽어주십시오.</p>';
				$rval .= '<textarea>';
				$rval .= read_file('./gpl-3.0.txt');
				$rval .= '</textarea>';
				$rval .= '<div class="buttongrp">';
				$rval .= form_button(array('name' => 'submit', 'type' => 'submit', 'content' => '<i class="fa fa-chevron-right"></i>'));
				$rval .= '</div>';
				$rval .= form_close();
				break;
			}
			case 2:
			{
				$attr = array('step' => '3');
				$rval .= form_open('install', '', $attr);
				$rval .= '<p>설치를 계속 진행하기 위해서는 다음 폴더의 권한이 <strong>707</strong> 또는 <strong>777</strong> 이어야 합니다.</p>';
				$rval .= '<p><ul><li>\'conf\' 폴더: ';

				// 폴더 권한 확인
				$dirChk = octal_permissions(fileperms('./conf'));
				if ($dirChk == "707" || $dirChk == "777") {
					$rval .= '<strong class="green">' . $dirChk . '</strong> (' . symbolic_permissions(fileperms('./conf')) . ')';
					$rval .= '</li></ul>';
					$rval .= '</p>';
					$rval .= '<div class="buttongrp">';
					$rval .= form_button(array('name' => 'submit', 'type' => 'submit', 'content' => '<i class="fa fa-chevron-right"></i>'));
					$rval .= '</div>';
				} else {
					$rval .= '<strong class="red">' . $dirChk . '</strong> (' . symbolic_permissions(fileperms('./conf')) . ')';
					$rval .= '</li></ul>';
					$rval .= '</p>';
					$rval .= '<div class="buttongrp">';
					$rval .= form_button(array('name' => 'nosubmit', 'type' => 'submit', 'content' => '<i class="fa fa-chevron-right"></i>'));
					$rval .= '</div>';
				}
				$rval .= form_close();
				
				break;
			}
			case 3:
			{
				$attr = array('step' => '4');
				$rval .= form_open('install', '', $attr);
				$rval .= '<p>현 단계에서는 설정된 데이터베이스에 앞으로 \'' . PRODUCT_NAME . '\'을 이용하기 위해 필요한 데이터 구조를 설치하게 됩니다.</p>';
				$rval .= '<p>여기서 설치되는 데이터 구조는 앞으로 게임 서버 및 웹 패널에서 \'' . PRODUCT_NAME . '\'을 이용하는데 있어 반드시 필요한 구조입니다.</p>';
				$rval .= '<p>계속 진행하시려면 진행 버튼을 누르십시오.</p>';
				$rval .= '<div class="buttongrp">';
				$rval .= form_button(array('name' => 'submit', 'type' => 'submit', 'content' => '<i class="fa fa-chevron-right"></i>'));
				$rval .= '</div>';
				$rval .= form_close();
				break;
			}
			case 4:
			{
				$attr = array('step' => '5');
				$rval .= form_open('install', '', $attr);

				// 데이터베이스 설치
				$rval .= '<p>데이터베이스 설치: ';
				$sqlPath = read_file(CONFIG_PATH . '/install.sql');
				if (!$sqlPath) {
					$rval .= '<strong class="red">SQL 파일이 없습니다.</strong></p>';
				} else {
					// 식별자 ';'' 기준으로 분리
					$sqls = explode(';', $sqlPath);
					// 쓸모없는 것은 제거
					array_pop($sqls);
					// 쿼리 한 줄마다 실행
					$qRst;
					foreach ($sqls as $q) {
						$q = $q . ';';
						$qRst = $this->db->query($q);
					}

					if (!$qRst) {
						$rval .= '<strong class="red">설치 도중 오류가 발생했습니다.</strong></p>';
					} else {
						$rval .= '<strong class="green">정상적으로 설치되었습니다.</strong></p>';
					}
				}

				$rval .= '<div class="buttongrp">';
				$rval .= form_button(array('name' => 'submit', 'type' => 'submit', 'content' => '<i class="fa fa-chevron-right"></i>'));
				$rval .= '</div>';
				$rval .= form_close();
				break;
			}
			case 5:
			{
				$attr = array('step' => '6');
				$rval .= form_open('install', '', $attr);
				$rval .= '<p>최종적으로 웹 패널을 이용하기 위해서는 스팀 Web API Key가 필요합니다.</p>';
				$rval .= '<p>\'' . PRODUCT_NAME . '\'는 스팀 API를 이용하여 편하게 웹 패널에 들어가고 자세한 정보를 확인할 수 있으며 관리도 손쉽게 할 수 있도록 도와줍니다.</p>';
				$rval .= '<p>스팀 Web API Key 는 <a href="http://steamcommunity.com/dev/apikey" target="_blank">여기</a>로 들어가셔서 발급받을 수 있습니다.<br>받은 32자리 API Key를 아래의 입력란에 써주십시오.</p>';
				$rval .= '<label for="apikey">Key 입력</label>' . form_input(array('id' => 'apikey', 'name' => 'apikey', 'maxlength' => '32'));
				$rval .= '<div class="buttongrp">';
				$rval .= form_button(array('name' => 'submit', 'type' => 'submit', 'content' => '<i class="fa fa-chevron-right"></i>'));
				$rval .= '</div>';
				$rval .= form_close();
				break;
			}
			case 6:
			{
				$attr = array('step' => '7', 'apikey' => $this->input->post('apikey', TRUE));
				$rval .= form_open('install', '', $attr);
				$rval .= '<p>최종적으로 모든 준비가 완료되었습니다.</p>';
				$rval .= '<p>진행 버튼을 누르시면 마지막 설정 준비와 함께 웹 패널로 들어가게 됩니다.</p>';
				$rval .= '<p>모든 것이 완료되면 게임 내에서나 웹 패널에서나 자유롭게 사용하실 수 있습니다.</p>';
				$rval .= '<div class="buttongrp">';
				$rval .= form_button(array('name' => 'submit', 'type' => 'submit', 'content' => '<i class="fa fa-check"></i>'));
				$rval .= '</div>';
				$rval .= form_close();
				break;
			}
			case 7:
			{
				// 설정 파일 작성
				$rval .= '<p>설정 파일 작성: ';
				if (!write_file(CONFIG_PATH . '/config.php', $this->input->post('apikey', TRUE))) {
					$rval .= '<strong class="red">설정 파일을 제작하지 못했습니다.</strong></p>';
				} else {
					$rval .= '<strong class="green">정상적으로 작성되었습니다.</strong></p>';
				}
				redirect('/home/');
				break;
			}
		}

		return $rval;
	}
}

?>
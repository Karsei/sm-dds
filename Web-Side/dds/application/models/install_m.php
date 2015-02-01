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
			array(5, '완료'),
			array(6, '홈 이동')
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
				$rval .= '<p>\'Dynamic Dollar Shop\'을 설치할 것입니다. 아래의 GPL v3 라이센스를 읽어주십시오.</p>';
				$rval .= '<textarea>';
				$rval .= read_file('./gpl-3.0.txt');
				$rval .= '</textarea>';
				$rval .= '<div class="buttongrp">';
				$rval .= form_submit('submit', '>');
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
					$rval .= form_submit('submit', '>');
					$rval .= '</div>';
				} else {
					$rval .= '<strong class="red">' . $dirChk . '</strong> (' . symbolic_permissions(fileperms('./conf')) . ')';
					$rval .= '</li></ul>';
					$rval .= '</p>';
					$rval .= '<div class="buttongrp">';
					$rval .= form_submit('nosubmit', '>');
					$rval .= '</div>';
				}
				$rval .= form_close();
				
				break;
			}
			case 3:
			{
				$attr = array('step' => '4');
				$rval .= form_open('install', '', $attr);
				$rval .= '<p>현 단계에서는 설정된 데이터베이스에 앞으로 \'Dynamic Dollar Shop\'을 이용하기 위해 필요한 데이터 구조를 설치하게 됩니다.</p>';
				$rval .= '<p>여기서 설치되는 데이터 구조는 앞으로 게임 서버 및 웹 패널에서 \'Dynamic Dollar Shop\'을 이용하는데 있어 반드시 필요한 구조입니다.</p>';
				$rval .= '<p>계속 진행하시려면 진행 버튼을 누르십시오.</p>';
				$rval .= '<div class="buttongrp">';
				$rval .= form_submit('submit', '>');
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
				$sqlPath = read_file(DDS_CONFIG_PATH . '/install.sql');
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

				// 설정 파일 작성
				$rval .= '<p>설정 파일 작성: ';
				if (!write_file(DDS_CONFIG_PATH . '/config.php', 'YAI!')) {
					$rval .= '<strong class="red">설정 파일을 제작하지 못했습니다.</strong></p>';
				} else {
					$rval .= '<strong class="green">정상적으로 작성되었습니다.</strong></p>';
				}
				$rval .= '<div class="buttongrp">';
				$rval .= form_submit('submit', '>');
				$rval .= '</div>';
				$rval .= form_close();
				break;
			}
			case 5:
			{
				$attr = array('step' => '6');
				$rval .= form_open('install', '', $attr);
				$rval .= '<p>설치가 모두 완료되었습니다.</p>';
				$rval .= '<p>이제 게임 서버 내에서 플러그인과 웹 패널을 사용하실 수 있습니다.</p>';
				$rval .= '<p></p>';
				$rval .= '<div class="buttongrp">';
				$rval .= form_submit('submit', '○');
				$rval .= '</div>';
				$rval .= form_close();
				break;
			}
			case 6:
			{
				redirect('/home/');
				break;
			}
		}

		return $rval;
	}
}

?>
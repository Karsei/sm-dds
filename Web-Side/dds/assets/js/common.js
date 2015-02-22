/**
 *
 * Dynamic Dollar Shop (DDS)
 * - Main Javascript file
 *
 * Author By. Karsei
 * (c) 2012 - 2015 
 *
 * http://karsei.pe.kr
 *
 */

/**
 * 쿠키 가져오기
 *
 * @param name				쿠키 값 이름
 */
function getCookie(name) {
	name = name + '=';
	var cData = document.cookie;
	var wantIdx = cData.indexOf(name);
	var rval = '';

	if (wantIdx != -1) {
		wantIdx += name.length;
		
		var endIdx = cData.indexOf(';', wantIdx);
		if (endIdx == -1)
			endIdx = cData.length;

		rval = cData.substring(wantIdx, endIdx);
	}
	return unescape(rval);
}

/**
 * 프로그래스 바 초기화
 */
function initProgress() {
	// 프로그래스 바 설정
	NProgress.start();
	NProgress.done();
	// 프로그래스 바 설정(ajax)
	$(document).ajaxStart(function() {
		NProgress.start();
		NProgress.done();
	});
}

/**
 * 목록 가져오기
 *
 * @param stype				행동 타입
 * @param starget			목록 타겟
 * @param spage				페이지 번호
 */
function loadList(stype, starget, spage)
{
	var controller = 'rlist';

	// 매개변수가 할당되어 있지 않을 때 처리
	spage = typeof spage !== 'undefined' ? spage : 1;

	// 실행
	$.ajax({
		url: base_Url + controller + '/getList',
		type: 'POST',
		data: {
			'dds_t': getCookie('dds_c'), 
			't': stype, 
			'p': spage
		},
		success: function(data) {
			if (data) {
				$(starget).html(data);
			}
		}
	});
}

/**
 * 목록 설정하기
 *
 * @param stype				행동 타입
 * @param sdetail			세부 행동 타입
 * @param starget			목록 타겟
 * @param sodata			첫 번째 데이터 값
 * @param stdata			두 번째 데이터 값
 * @param spage				페이지 번호
 */
function doProcess(stype, sdetail, starget, sodata, stdata, spage)
{
	var controller = 'rlist';

	// 매개변수가 할당되어 있지 않을 때 처리
	stdata = typeof stdata !== 'undefined' ? stdata : 0;
	spage = typeof spage !== 'undefined' ? spage : 1;

	// 실행
	$.ajax({
		url: base_Url + controller + '/doProcess',
		type: 'POST',
		data: {
			'dds_t': getCookie('dds_c'), 
			't': sdetail, 
			'odata': sodata, 
			'tdata': stdata
		},
		success: function(data) {
			// 다시 목록을 로드
			loadList(stype, starget, spage);
			// Json 파싱
			var jdata = $.parseJSON(data);
			loadPromptMsg(jdata.title, jdata.msg);
		}
	});
}

/**
 * 버튼이 하나인 알림창 열기
 *
 * @param title				제목
 * @param msg				메세지
 */
function loadPromptMsg(title, msg)
{
	var controller = 'msg';

	$.ajax({
		url: base_Url + controller + '/loadPromptMsg',
		type: 'POST',
		data: {
			'dds_t': getCookie('dds_c'), 
			'title': title,
			'msg': msg
		},
		success: function(data) {
			// Json 파싱
			var jdata = $.parseJSON(data);
			$.prompt(jdata.msg, {
				title: jdata.title,
				buttons: {"O": true}
			});
		}
	});
}

/**
 * 버튼이 두 개인 알림창 열기
 *
 * @param title				제목
 * @param msg				메세지
 * @param func				O 버튼을 누를 시 실행될 함수
 */
function loadPromptMsg2(title, msg, func)
{
	var controller = 'msg';

	$.ajax({
		url: base_Url + controller + '/loadPromptMsg',
		type: 'POST',
		data: {
			'dds_t': getCookie('dds_c'), 
			'title': title,
			'msg': msg
		},
		success: function(data) {
			// Json 파싱
			var jdata = $.parseJSON(data);
			$.prompt(jdata.msg, {
				title: jdata.title,
				buttons: {"O": true, "X": false},
				submit: function (e, v, m, f) {
					if (v) {
						func();
					}
				}
			});
		}
	});
}

/**
 * 번역 로드
 *
 * @param msg				메세지
 * @param getStr			콜백 함수
 */
function loadTransMsg(msg, getStr)
{
	var controller = 'msg';

	$.ajax({
		url: base_Url + controller + '/loadTransMsg',
		type: 'POST',
		data: {
			'dds_t': getCookie('dds_c'), 
			'msg': msg
		},
		success: function(data) {
			getStr(data);
		}
	});
}

// 최초 실행
;$(function($) {
	// 프로그래스 바 설정
	initProgress();

	// API KEY 입력 시
	$('#apikey').on('keyup', function() {
		var $key = $('#apikey').val();

		// 적어도 32글자는 입력해야 함
		if ($key.length >= 32)
		{
			$('#apisubmit').attr({
				'name': 'submit',
				'type': 'submit'
			});
		}
		else
		{
			$('#apisubmit').attr({
				'name': 'nosubmit',
				'type': 'button'
			});
		}
	});

	/** 목록 클릭 관련 **/
	$(document).on('click', '.detail-pagination td', function() {
		loadList($(this).attr('data-t'), $(this).attr('data-tar'), $(this).html());
	});
	$(document).on('click', '.myinfo-list .btnapl', function() {
		// 목록 갱신 관련
		var sType = $(this).attr('data-t'); var sPage = $(this).attr('data-p');

		// 목록 설정 관련
		var sDetail = $(this).attr('data-dt'); 
		var sIlIdx = $(this).attr('data-ilidx'); 
		var sIcIdx = $(this).attr('data-icidx');
		loadPromptMsg2('msg_title_notice', 'msg_contents_itemuse', (function() {
			doProcess(sType, sDetail, '.myinfo-list', sIlIdx, sIcIdx, sPage);
		}));
	});
	$(document).on('click', '.myinfo-list .btnaplcan', function() {
		// 목록 갱신 관련
		var sType = $(this).attr('data-t'); var sPage = $(this).attr('data-p');

		// 목록 설정 관련
		var sDetail = $(this).attr('data-dt');
		var sIlIdx = $(this).attr('data-ilidx');
		var sIcIdx = $(this).attr('data-icidx');
		loadPromptMsg2('msg_title_notice', 'msg_contents_itemcancel', (function() {
			doProcess(sType, sDetail, '.myinfo-list', sIlIdx, sIcIdx, sPage);
		}));
	});
	$(document).on('click', '.myinfo-list .btndrop', function() {
		// 목록 갱신 관련
		var sType = $(this).attr('data-t'); var sPage = $(this).attr('data-p');

		// 목록 설정 관련
		var sDetail = $(this).attr('data-dt');
		var sIlIdx = $(this).attr('data-ilidx');
		loadPromptMsg2('msg_title_notice', 'msg_contents_itemdrop', (function() {
			doProcess(sType, sDetail, '.myinfo-list', sIlIdx, 0, sPage);
		}));
	});
	$(document).on('click', '.buy-list .btnbuy', function() {
		// 목록 갱신 관련
		var sType = $(this).attr('data-t'); var sPage = $(this).attr('data-p');

		// 목록 설정 관련
		var sDetail = $(this).attr('data-dt');
		var sUsrAuth = $(this).attr('data-aid');
		var sIlIdx = $(this).attr('data-ilidx');
		loadPromptMsg2('msg_title_notice', 'msg_contents_itembuy', (function() {
			doProcess(sType, sDetail, '.buy-list', sIlIdx, 0, sPage);
		}));
	});
	$(document).on('click', '.sub-ad-gnb li', function() {
		var $getTarget = $(this).find('span');
		var $tgType = $getTarget.attr('data-t');
		loadList($tgType, '.admin-list', base_Url, 1);
	});
	$(document).on('click', '.admin-list .btnusrmodify', function() {
		var $mtable = $(this); // 선택 칼럼
		var $mtarget; // 금액 칼럼

		// 목록 설정 관련
		var sType = $(this).attr('data-t'); var sDetail = $(this).attr('data-dt');
		var usrIdx = $mtable.attr('data-uidx'); var sPage = $(this).attr('data-p');

		// 참조 자료
		var usrMoney = '';

		// 위치 획득
		$('.usrmoney').each(function() {
			if ($(this).attr('data-uidx') == usrIdx) {
				$mtarget = $(this);
			}
		});

		// 행동 구분
		loadTransMsg('btn_done', function(done_output)
		{
			if ($mtable.html() == done_output)
			{
				var modmoney = $mtarget.find('input').val();
				loadTransMsg('btn_modify', function(mod_output) {
					$mtable.html(mod_output);
					$mtarget.html(modmoney);
				});
				doProcess(sType, sDetail, '', usrIdx, modmoney, sPage);
			}
			else
			{
				usrMoney = $mtarget.html();
				$mtarget.html('<input type="text" value="' + usrMoney + '">');
			
				$mtable.html(done_output);
			}
		});
	});
});
function switchSet(mainE) {
	document.getElementById('gloLoad').style.display = "none";
	document.getElementById(mainE).style.display = "";
}

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
 * 목록 가져오기
 *
 * @param stype				행동 타입
 * @param said				유저 고유번호
 * @param surl				사이트 절대 경로
 * @param spage				페이지 번호
 */
function loadList(stype, said, surl, spage)
{
	var control = 'rlist';
	var baseUrl = surl;
	var starget = '';

	// 매개변수가 할당되어 있지 않을 때 처리
	spage = typeof spage !== 'undefined' ? spage : 1;

	// 해당 행동으로 값이 변할 타겟을 정하는 곳
	if (stype == 'inven')	starget = '.myinfo-list';
	else if (stype == 'buy')	starget = '.buy-list';
	else if (stype == 'usrlist')	starget = '.admin-list';

	// 실행
	$.ajax({
		url: baseUrl + control + '/getList',
		type: 'POST',
		data: {'dds_t': getCookie('dds_c'), 't': stype, 'p': spage},
		success: function(data) {
			var $blistTg = $(starget);
			if (data) {
				$blistTg.html(data);
			}
		}
	});
}

/**
 * 목록 설정하기
 *
 * @param stype				행동 타입
 * @param sdest				세부 행동 타입
 * @param said				유저 고유번호
 * @param surl				사이트 절대 경로
 * @param soidx				첫 번째 데이터 값
 * @param stidx				두 번째 데이터 값
 * @param spage				페이지 번호
 */
function doProcess(stype, sdest, said, surl, soidx, stidx, spage)
{
	var control = 'rlist';
	var authId = said;
	var baseUrl = surl;

	// 매개변수가 할당되어 있지 않을 때 처리
	stidx = typeof stidx !== 'undefined' ? stidx : 0;
	spage = typeof spage !== 'undefined' ? spage : 1;

	// 실행
	$.ajax({
		url: baseUrl + control + '/doProcess',
		type: 'POST',
		data: {'dds_t': getCookie('dds_c'), 't': sdest, 'oidx': soidx, 'tidx': stidx},
		success: function(data) {
			// 다시 목록을 로드
			loadList(stype, authId, baseUrl, spage);

			// 알림 창 작성
			if (data == "true") // 정상적으로 처리되었을 때
			{
				$.prompt("정상적으로 처리되었습니다.", {
					title: "알림",
					buttons: {"확인": true}
				});
			}
			else // 오류가 발생했을 때
			{
				if (data == "err-moneymore")
				{
					$.prompt("금액이 부족합니다.", {
						title: "알림",
						buttons: {"확인": true}
					});
				}
				else if (data == "err-ingame")
				{
					$.prompt("현재 게임 내에 있으면 실행하실 수 없습니다.", {
						title: "알림",
						buttons: {"확인": true}
					});
				}
				else
				{
					$.prompt("요청을 실행하다가 오류가 발생했습니다.<p>오류 원인: " + data + "</p>", {
						title: "알림",
						buttons: {"확인": true}
					});
				}
			}
		},
		complete: function(data) {
			/*console.log('Complete');*/
		},
		error: function(xhr, status, error) {
			/*console.log('error!');
			console.log(error);*/
		}
	});
}

;$(function($) {
	// 프로그래스 바 설정
	NProgress.start();
	NProgress.done();
	// 프로그래스 바 설정(ajax)
	$(document).ajaxStart(function() {
		NProgress.start();
		NProgress.done();
	});

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
		loadList($(this).attr('data-t'), $(this).attr('data-aid'), $(this).attr('data-url'), $(this).html());
	});
	$(document).on('click', '.myinfo-list .btnapl', function() {
		var sDetail = $(this).attr('data-dt'); var sType = $(this).attr('data-t');
		var sUsrAuth = $(this).attr('data-aid'); var sUrl = $(this).attr('data-url');
		var sIlIdx = $(this).attr('data-ilidx'); var sPage = $(this).attr('data-p');
		var sIcIdx = $(this).attr('data-icidx');
		$.prompt("정말로 해당 아이템을 장착하시겠습니까?", {
			title: "아이템 장착",
			buttons: {"확인": true, "취소": false },
			submit: function(e, v, m, f) {
				if (v)	doProcess(sType, sDetail, sUsrAuth, sUrl, sIlIdx, sIcIdx, sPage);
			}
		});
	});
	$(document).on('click', '.myinfo-list .btnaplcan', function() {
		var sDetail = $(this).attr('data-dt'); var sType = $(this).attr('data-t');
		var sUsrAuth = $(this).attr('data-aid'); var sUrl = $(this).attr('data-url');
		var sIlIdx = $(this).attr('data-ilidx'); var sPage = $(this).attr('data-p');
		var sIcIdx = $(this).attr('data-icidx');
		$.prompt("정말로 해당 아이템을 장착 해제하시겠습니까?", {
			title: "아이템 장착 해제",
			buttons: {"확인": true, "취소": false },
			submit: function(e, v, m, f) {
				if (v)	doProcess(sType, sDetail, sUsrAuth, sUrl, sIlIdx, sIcIdx, sPage);
			}
		});
	});
	$(document).on('click', '.myinfo-list .btndrop', function() {
		var sDetail = $(this).attr('data-dt'); var sType = $(this).attr('data-t');
		var sUsrAuth = $(this).attr('data-aid'); var sUrl = $(this).attr('data-url');
		var sIlIdx = $(this).attr('data-ilidx'); var sPage = $(this).attr('data-p');
		$.prompt("정말로 해당 아이템을 버리시겠습니까?", {
			title: "아이템 버리기",
			buttons: {"확인": true, "취소": false },
			submit: function(e, v, m, f) {
				if (v)	doProcess(sType, sDetail, sUsrAuth, sUrl, sIlIdx, 0, sPage);
			}
		});
	});
	$(document).on('click', '.buy-list .btnbuy', function() {
		var sDetail = $(this).attr('data-dt'); var sType = $(this).attr('data-t');
		var sUsrAuth = $(this).attr('data-aid'); var sUrl = $(this).attr('data-url');
		var sIlIdx = $(this).attr('data-ilidx'); var sPage = $(this).attr('data-p');
		$.prompt("해당 아이템을 구입하시겠습니까?", {
			title: "아이템 구매",
			buttons: {"확인": true, "취소": false },
			submit: function(e, v, m, f) {
				if (v)	doProcess(sType, sDetail, sUsrAuth, sUrl, sIlIdx, 0, sPage);
			}
		});
	});
	$(document).on('click', '.admin-list .btnusrmodify', function() {
		var $mtable = $(this); var $mtarget;
		var usrIdx = $mtable.attr('data-uidx'); var sUsrAuth = $(this).attr('data-aid');
		var sUrl = $(this).attr('data-url'); var sPage = $(this).attr('data-p');
		var sType = $(this).attr('data-t'); var sDetail = $(this).attr('data-dt');
		var usrMoney = '';

		// 위치 획득
		$('.usrmoney').each(function() {
			if ($(this).attr('data-uidx') == usrIdx) {
				$mtarget = $(this);
			}
		});

		// 행동 구분
		if ($mtable.html() == '완료')
		{
			$mtable.html('수정');
			var modmoney = $mtarget.find('input').val();
			$mtarget.html(modmoney);
			doProcess(sType, sDetail, sUsrAuth, sUrl, usrIdx, modmoney, sPage);
		}
		else
		{
			usrMoney = $mtarget.html();
			$mtarget.html('<input type="text" value="' + usrMoney + '">');
			$mtable.html('완료');
		}
	});
});
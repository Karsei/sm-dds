function switchSet(mainE) {
	document.getElementById('gloLoad').style.display = "none";
	document.getElementById(mainE).style.display = "";
}

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

function loadList(stype, usrauthid, surl, spage)
{
	var control = 'rlist';
	var authId = usrauthid;
	var baseUrl = surl;
	var starget = '';

	spage = typeof spage !== 'undefined' ? spage : 1;

	if (stype == 'inven')	starget = '.myinfo-list';
	else if (stype == 'buy')	starget = '.buy-list';
	else if (stype == 'usrlist')	starget = '.admin-list';

	$.ajax({
		url: baseUrl + control + '/getList',
		type: 'POST',
		data: {'dds_t': getCookie('dds_c'), 't': stype, 'p': spage},
		success: function(data) {
			var $blistTg = $(starget);
			//console.log(data);
			if (data) {
				$blistTg.html(data);
			}
		}
	});
}

function doProcess(stype, sdest, usrauthid, surl, silidx, spage)
{
	//console.log(stype);

	var control = 'rlist';
	var authId = usrauthid;
	var baseUrl = surl;

	spage = typeof spage !== 'undefined' ? spage : 1;

	$.ajax({
		url: baseUrl + control + '/doProcess',
		type: 'POST',
		data: {'dds_t': getCookie('dds_c'), 't': sdest, 'idx': silidx},
		success: function(data) {
			console.log(data);
			loadList(stype, authId, baseUrl, spage);
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
	NProgress.start();
	NProgress.done();
	$(document).ajaxStart(function() {
		NProgress.start();
		NProgress.done();
	});

	// API KEY 입력 시
	$('#apikey').on('keyup', function() {
		var $key = $('#apikey').val();
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
		$.prompt("정말로 해당 아이템을 장착하시겠습니까?", {
			title: "아이템 장착",
			buttons: {"확인": true, "취소": false },
			submit: function(e, v, m, f) {
				if (v)	doProcess(sType, sDetail, sUsrAuth, sUrl, sIlIdx);
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
				if (v)	doProcess(sType, sDetail, sUsrAuth, sUrl, sIlIdx);
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
				if (v)	doProcess(sType, sDetail, sUsrAuth, sUrl, sIlIdx);
			}
		});
	});
});
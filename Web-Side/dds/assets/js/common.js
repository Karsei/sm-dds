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
			//console.log($blistTg);
			if (data) {
				$blistTg.html(data);
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
	NProgress.start();
	NProgress.done();
	$(document).ajaxStart(function() {
		NProgress.start();
		NProgress.done();
	});
	
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

	$(document).on('click', '.detail-pagination td', function() {
		loadList($(this).attr('data-t'), $(this).attr('data-aid'), $(this).attr('data-url'), $(this).html());
	});
});
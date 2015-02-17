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

function loadList(stype, starget, usrauthid, surl)
{
	var control = 'rlist';
	var authId = usrauthid;
	var baseUrl = surl;

	$.ajax({
		url: baseUrl + control + '/getList',
		type: 'POST',
		data: {'dds_t': getCookie('dds_c'), 't': stype},
		success: function(data) {
			var $blistTg = $(starget + ' tbody');
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
});
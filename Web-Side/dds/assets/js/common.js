function switchSet(mainE) {
	document.getElementById('gloLoad').style.display = "none";
	document.getElementById(mainE).style.display = "";
}

$(document).ready(function() {
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
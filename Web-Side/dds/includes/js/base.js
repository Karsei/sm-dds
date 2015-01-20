function Frm_Check1(form1) {
	if(!form1.userid.value) {
		alert('아이디를 입력해주세요.');
		form1.userid.focus();
		return false;
	}
	if(!form1.userpass.value) {
		alert('비밀번호를 입력해주세요.');
		form1.userpass.focus();
		return false;
	} else {
		return true;
	}
}

function sendInfo(arrnum, ddsusern, ddsitinfo)
{
	var getitstr = ddsitinfo.split("^");
	var tarinfo = document.getElementById('showinfo_sub');
	
	tarinfo.innerHTML = "";
	tarinfo.innerHTML += "<p> * 해당 로그 시각의 <b>" + ddsusern + "</b> 님 장착 아이템 정보입니다.</p>";
	tarinfo.innerHTML += "<p>&nbsp;</p>";
	
	for (var itn = 0; itn < arrnum; itn++)
	{
		tarinfo.innerHTML += "<p><b>아이템 종류 " + (itn + 1) + "번:</b> " + getitstr[itn] + "</p>";
	}
}
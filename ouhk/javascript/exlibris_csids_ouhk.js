function logoutRedirectCSIDS(){
	var alink = $("#exlidMyShelf a").attr("href");
	if(alink.indexOf("login.do?loginFn=signin") == -1){
	}   
	alink = $("#exlidMyAccount a").attr("href");
	if(alink.indexOf("login.do?loginFn=signin") == -1){

	}   
	alink = $("#exlidSignOut a").attr("href");
	var target_s=alink.indexOf("targetURL");
	alink = alink.substr(0,target_s);
	$("#exlidSignOut a").attr("href",alink + "targetURL=http%3a%2f%2fprimo2.csids.edu.hk%2fprimo_library%2flibweb%2fouhk%2fstatic_html%2flogout.html");
} //end logoutRedirectCSIDS()

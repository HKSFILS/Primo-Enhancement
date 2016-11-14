function logoutRedirectOUHK(){
	/*********************************************************
			 Adding redirect logout
	********************************************************/
 	var alink = $("#exlidSignOut a").attr("href");
	var target_s=alink.indexOf("targetURL");
	alink = alink.substr(0,target_s);
	if(alink.indexOf("logout") > -1){
		$("#exlidSignOut a").attr("href",alink + "targetURL=http%3a%2f%2fprimo.lib.ouhk.edu.hk%2fprimo_library%2flibweb%2fstatic_htmls%2fouhk%2flogout.html");
	}
} //end logoutRedirectOUHK()

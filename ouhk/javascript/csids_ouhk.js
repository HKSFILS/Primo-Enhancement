//The function chnageing the My Account Linking problems. 
function changeMyACURLCSIDS(){
	var currentUrl = window.location.href;
	var userName = document.getElementById("exlidUserName").innerHTML;
	if(userName.toUpperCase().indexOf('GUEST') >= 0 && (currentUrl.toUpperCase().indexOf('BASKET') >=0 
		|| currentUrl.toUpperCase().indexOf('SESSIONQUERY'))){
		document.getElementById("exlidMyAccount").getElementsByTagName("a")[0].href =
			"login.do?loginFn=signin&targetURL=basket.do?fn=display&fromUserArea=true&vid=OUHK&fromPreferences=false";
		document.getElementsByClassName('EXLMyAccount')[0].href =
			"login.do?loginFn=signin&targetURL=basket.do?fn=display&fromUserArea=true&vid=OUHK&fromPreferences=false";
		if(document.getElementById("exlidMyAccountTab") != null){
			document.getElementById("exlidMyAccountTab").getElementsByTagName("a")[0].href =
				"login.do?loginFn=signin&targetURL=basket.do?fn=display&fromUserArea=true&vid=OUHK&fromPreferences=false";
			document.getElementsByClassName('EXLMyAccountTab EXLMyAccountSelectedTab EXLMyAccountLastTab')[0].href =
				"login.do?loginFn=signin&targetURL=basket.do?fn=display&fromUserArea=true&vid=OUHK&fromPreferences=false";
		} //end if
	} //end if

	userName = document.getElementsByClassName('EXLUserNameDisplay')[0].innerHTML;
	if(userName.toUpperCase().indexOf('GUEST') >= 0 && (currentUrl.toUpperCase().indexOf('BASKET') >=0 
		|| currentUrl.toUpperCase().indexOf('SESSIONQUERY'))){
		document.getElementById("exlidMyAccount").getElementsByTagName("a")[0].href =
			"login.do?loginFn=signin&targetURL=basket.do?fn=display&fromUserArea=true&vid=OUHK&fromPreferences=false";
		document.getElementsByClassName('EXLMyAccount')[0].href =
			"login.do?loginFn=signin&targetURL=basket.do?fn=display&fromUserArea=true&vid=OUHK&fromPreferences=false";
		if(document.getElementById("exlidMyAccountTab") != null){
			document.getElementById("exlidMyAccountTab").getElementsByTagName("a")[0].href =
				"login.do?loginFn=signin&targetURL=basket.do?fn=display&fromUserArea=true&vid=OUHK&fromPreferences=false";
			document.getElementsByClassName('EXLMyAccountTab EXLMyAccountSelectedTab EXLMyAccountLastTab')[0].href =
				"login.do?loginFn=signin&targetURL=basket.do?fn=display&fromUserArea=true&vid=OUHK&fromPreferences=false";
		} //end if
	} //end if

} //end changeMyACURLCSIDS()

//The function clearAdvSearchYear() is by OUHK LIB QSYS (William NG) for hiding the default values for the advanced search field "Year". Dated 2 Sep 2015.
function clearAdvSearchYearCSIDS(){
	var startYearInput = document.getElementById("input_5168341UI4");
	var endYearInput = document.getElementById("input_5168344UI4");
	if(startYearInput != null){
		startYearInput.value = "";
		startYearInput.placeholder = "";
	} //end if
	if(endYearInput != null){
		endYearInput.value = "";
		endYearInput.placeholder = "";
	} //end if
} //end clearAdvSearchYearCSIDS()

//The function sleep() is by OUHK LIB QSYS (William NG) for having some sleep time while running Javascript. Dated: 24 Nov 2015.
function sleep(milliseconds) {
	var start = new Date().getTime();
	for (var i = 0; i < 1e7; i++) {
		if ((new Date().getTime() - start) > milliseconds){
			break;
		}
	}
} //end sleep()

//The function changeDueDateCSIDS() change the due date formats in more readable form. By William NG (LIB QSYS) Dated 3 Feb 2016.
function changeDueDateCSIDS(){
	var duedates = document.getElementsByClassName("MyAccount_Loans_dueDate");
	var addedes = document.getElementsByClassName("added");
	var lang_tw = document.getElementsByClassName("EXLCurrentLang_zh_TW");
	var lang_us = document.getElementsByClassName("EXLCurrentLang_en_US");
	var lang_cn = document.getElementsByClassName("EXLCurrentLang_zh_CN");
	var months={"01":"Jan", "02":"Feb", "03":"Mar", "04":"Apr", "05":"May", "06":"Jun",
		"07":"Jul", "08":"Aug", "09":"Sep", "10":"Oct", "11":"Nov", "12":"Dec"}

	var months_chi={"01":"1月", "02":"2月", "03":"3月", "04":"4月", "05":"5月", "06":"6月",
		"07":"7月", "08":"8月", "09":"9月", "10":"10月", "11":"11月", "12":"12月"}
	if(duedates != null){
		if(lang_us[0] != null){
			for(var i=0; i<duedates.length; i++){
				var tmp = duedates[i].innerHTML
					if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
						tmp=RegExp.$1+"-"+months[RegExp.$2]+"-"+RegExp.$3;
							duedates[i].innerHTML = tmp;
					} //end if
			} //end for
		} else if(lang_tw[0] != null || lang_cn[0] != null){
			for(var i=0; i<duedates.length; i++){
				var tmp = duedates[i].innerHTML
					if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
						tmp=RegExp.$1+"-"+months_chi[RegExp.$2]+"-"+RegExp.$3;
							duedates[i].innerHTML = tmp;
					} //end if
			} //end for
		} //end if
	} //end if

	if(addedes != null){
		if(lang_us[0] != null){
			for(var i=0; i<addedes.length; i++){
				var tmp = addedes[i].innerHTML
					if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
						tmp=RegExp.$1+"-"+months[RegExp.$2]+"-"+RegExp.$3;
							addedes[i].innerHTML = tmp;
					} //end if
			} //end for
		} else if(lang_tw[0] != null || lang_cn[0] != null){
			for(var i=0; i<addedes.length; i++){
				var tmp = addedes[i].innerHTML
					if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
						tmp=RegExp.$1+"-"+months_chi[RegExp.$2]+"-"+RegExp.$3;
							addedes[i].innerHTML = tmp;
					} //end if
			} //end for
		} //end if
	} //end if
} //end changeDueDateCSIDS()

function changeLoansDetailsCSIDS(){
	var onLoansDetailsPage = false;
	var exlidMyAccountMainHeader = document.getElementById("exlidMyAccountMainHeader");
	if(exlidMyAccountMainHeader != null){
		var innerHTML = exlidMyAccountMainHeader.innerHTML;
		if (innerHTML.toLowerCase().indexOf("details of loan") >= 0
			|| innerHTML.toLowerCase().indexOf("借閱明細") >= 0
			|| innerHTML.toLowerCase().indexOf("借阅明细") >= 0) {
			onLoansDetailsPage = true;
		} //end if
	} else {
		onLoansDetailsPage = false;
	} //end if

	if(onLoansDetailsPage){
		var table = document.getElementsByClassName("EXLMyAccountTableDetails");
		var months={"01":"Jan", "02":"Feb", "03":"Mar", "04":"Apr", "05":"May", "06":"Jun",
				"07":"Jul", "08":"Aug", "09":"Sep", "10":"Oct", "11":"Nov", "12":"Dec"}
		var months_chi={"01":"1月", "02":"2月", "03":"3月", "04":"4月", "05":"5月", "06":"6月",
				"07":"7月", "08":"8月", "09":"9月", "10":"10月", "11":"11月", "12":"12月"}
		if(table[0] != null){
			var td = table[0].getElementsByTagName("td");
			for (a = 0; a < td.length; a++){
				if (td[a].innerHTML == "00000000"){
					table[0].deleteRow(a);
				} //end if
			} //end for
			for (var r = 0, n = table[0].rows.length; r < n; r++) {
				for (var c = 0, m = table[0].rows[r].cells.length; c < m; c++) {
					var cellValue = table[0].rows[r].cells[c].innerHTML;
					if (cellValue.toLowerCase().indexOf("due date") >= 0 
					|| cellValue.toLowerCase().indexOf("date of the last renewal") >= 0
					|| cellValue.toLowerCase().indexOf("loan date") >= 0){
						var tmp = table[0].rows[r].cells[c+1].innerHTML;
						if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
							tmp=RegExp.$1+"-"+months[RegExp.$2]+"-"+RegExp.$3;
							table[0].rows[r].cells[c+1].innerHTML = tmp;
						} //end if
						if(table[0].rows[r+1].cells[c+1].innerHTML != 0
						&& cellValue.toLowerCase().indexOf("due date") >= 0){
							table[0].rows[r].cells[c+1].innerHTML
							= table[0].rows[r].cells[c+1].innerHTML + " at " +
							table[0].rows[r+1].cells[c+1].innerHTML;
							table[0].deleteRow(r+1);
						} //end if 
						if (cellValue.toLowerCase().indexOf("date of the last renewal") >= 0
						|| cellValue.toLowerCase().indexOf("loan date") >= 0
						&& table[0].rows[r+1].cells[c+1].innerHTML !=0){
							table[0].rows[r].cells[c+1].innerHTML
							= table[0].rows[r].cells[c+1].innerHTML;
						} //end if
					} //end if
					if (cellValue.indexOf("應還日期") >= 0
 					|| cellValue.indexOf("应还日期") >= 0 
					|| cellValue.indexOf("上次續借日期") >= 0 
					|| cellValue.indexOf("上次续借日期") >= 0 
					|| cellValue.indexOf("外借日期") >= 0 
					|| cellValue.indexOf("借出日期") >= 0){
					var tmp = table[0].rows[r].cells[c+1].innerHTML
						if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
							tmp=RegExp.$1+"-"+months_chi[RegExp.$2]+"-"+RegExp.$3;
							table[0].rows[r].cells[c+1].innerHTML = tmp;
						} //end if
						if (cellValue.indexOf("應還日期") >= 0  
						|| cellValue.indexOf("应还日期") >= 0 
						&& table[0].rows[r+1].cells[c+1].innerHTML != 0){
							table[0].rows[r].cells[c+1].innerHTML
							= table[0].rows[r].cells[c+1].innerHTML + " 在 " +
							table[0].rows[r+1].cells[c+1].innerHTML;
							table[0].deleteRow(r+1);
						} //end if
						if (cellValue.indexOf("上次續借日期") >= 0 
						|| cellValue.indexOf("上次续借日期") >= 0 
						|| cellValue.indexOf("外借日期") >= 0 
						|| cellValue.indexOf("借出日期") >= 0 
						&& table[0].rows[r+1].cells[c+1].innerHTML != 0){
							table[0].rows[r].cells[c+1].innerHTML
							= table[0].rows[r].cells[c+1].innerHTML;
						} //end if
					} //end if
				} //end for
			} //end for
		} //end if
	} //end if 
} //end changeLoansDetailsCSIDS()

function changeRequestsDetailsCSIDS(){
	var onRequestsDetailsPage = false;
	var exlidMyAccountMainHeader = document.getElementById("exlidMyAccountMainHeader");
	if(exlidMyAccountMainHeader != null){
		var innerHTML = exlidMyAccountMainHeader.innerHTML;
		if (innerHTML.toLowerCase().indexOf("details for") >= 0
			|| innerHTML.toLowerCase().indexOf("詳情") >= 0
			|| innerHTML.toLowerCase().indexOf("详情") >= 0) {
			onRequestsDetailsPage = true;
		} //end if
	} else {
		onRequestsDetailsPage = false;
	} //end if

	if(onRequestsDetailsPage){
		var table = document.getElementsByClassName("EXLMyAccountTableDetails");
		var months={"01":"Jan", "02":"Feb", "03":"Mar", "04":"Apr", "05":"May", "06":"Jun",
				"07":"Jul", "08":"Aug", "09":"Sep", "10":"Oct", "11":"Nov", "12":"Dec"}
		var months_chi={"01":"1月", "02":"2月", "03":"3月", "04":"4月", "05":"5月", "06":"6月",
				"07":"7月", "08":"8月", "09":"9月", "10":"10月", "11":"11月", "12":"12月"}
		if(table[0] != null){
		var td = table[0].getElementsByTagName("td");
		var th = table[0].getElementsByTagName("th");
			for (var a = 0; a < td.length; a++){
				for (var b= 0; b < a; b++){
					if (td[a].innerHTML == "00000000" 
					|| td[a].innerHTML == "000000000"){
						table[0].deleteRow(a);
					} //end if
					if (th[a].innerHTML.toLowerCase().includes("request date") 
					|| th[a].innerHTML.toLowerCase().includes("hold date")
					|| th[a].innerHTML.toLowerCase().includes("end hold date")
					|| th[a].innerHTML.toLowerCase().includes("due date")
					|| th[a].innerHTML.toLowerCase().includes("last interest date")
					|| th[a].innerHTML.toLowerCase().includes("update date")){
						var tmp = td[a].innerHTML;
						if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
							tmp=RegExp.$1+"-"+months[RegExp.$2]+"-"+RegExp.$3;
							td[a].innerHTML = tmp;
						} //end if
					} //end if
					if (th[a].innerHTML.toLowerCase().includes("請求日期") 
					|| th[a].innerHTML.toLowerCase().includes("请求日期") 
					|| th[a].innerHTML.toLowerCase().includes("預約日期") 
					|| th[a].innerHTML.toLowerCase().includes("預約完結日期") 
					|| th[a].innerHTML.toLowerCase().includes("预约完结日期") 
					|| th[a].innerHTML.toLowerCase().includes("预约日期") 
					|| th[a].innerHTML.toLowerCase().includes("到期日") 
					|| th[a].innerHTML.toLowerCase().includes("請求到期日期") 
					|| th[a].innerHTML.toLowerCase().includes("请求结束日期") 
					|| th[a].innerHTML.toLowerCase().includes("预约结束日期") 
					|| th[a].innerHTML.toLowerCase().includes("更新日期") 
					|| th[a].innerHTML.toLowerCase().includes("興趣檔最後日期") 
					|| th[a].innerHTML.toLowerCase().includes("兴趣档最后日期")  
					|| th[a].innerHTML.toLowerCase().includes("需求截止日期")){ 
						var tmp = td[a].innerHTML;
						if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
							tmp=RegExp.$1+"-"+months_chi[RegExp.$2]+"-"+RegExp.$3;
							td[a].innerHTML = tmp;
						} //end if
					} //end if
				} //end for
			} //end for
		} //end if
	} //end if
}//end changeRequestsDetailsCSIDS()

function changeFacetWordsToChiCSIDS(){
	if ($(".EXLCurrentLang_zh_TW")[0]){
		var ele = document.getElementById("exlidFacet5-1");
		if(ele.innerHTML.indexOf("Book") > 0 ){
			ele.innerHTML = "圖書";
		} //end if
		var ele = document.getElementById("exlidFacet5-0");
		if(ele.innerHTML.indexOf("Book") > 0 ){
			ele.innerHTML = "圖書";
		} //end if
		var ele = document.getElementById("exlidFacet5-2");
		if(ele.innerHTML.indexOf("Book") > 0 ){
			ele.innerHTML = "圖書";
		} //end if
		var ele = document.getElementById("exlidFacet5-3");
		if(ele.innerHTML.indexOf("Book") > 0 ){
			ele.innerHTML = "圖書";
		} //end if
	} //end if
} // changeFacetWordsToChi()

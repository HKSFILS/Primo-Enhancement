/*
 * This file stores core JavaScript functions which are used by CSIDS Primo Union Search.
 * */


//The function clearAdvSearchYear() is by OUHK LIB QSYS (William NG) for hiding the default values for the advanced search field "Year". Dated 2 Sep 2015.
function clearAdvSearchYear(){
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
} //end clearAdvSearchYear()

//The function sleep() is by OUHK LIB QSYS (William NG) for having some sleep time while running Javascript. Dated: 24 Nov 2015.
function sleep(milliseconds) {
	var start = new Date().getTime();
	for (var i = 0; i < 1e7; i++) {
		if ((new Date().getTime() - start) > milliseconds){
			break;
		}
	}
} //end sleep()

//The function prepareQViewOnlineTab() is by OUHK LIB QSYS (William NG) for preparing to display QSYS customized "View Online" Tab. Dated: 24 Nov 2015.
//This function should be run on every page on where QSYS customized "View Online" Tab appears.
//But for displaying the QSYS customized "View Online" Tab, "resultsTile.jsp" and "fullRecord.jsp" must be modified to insert "viewonline_tab.jsp",
//where "viewonline_tab.jsp" is in the folider:
//	"/exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/csids"
function prepareQViewOnlineTab(){
	var emptyFunction = function(){return true;};
	var qViewOnlineTabHandler =
		EXLTA_createWidgetTabHandler(function(element){return '<iframe src=/primo_library/libweb/csids/tiles/viewonline_tab.jsp?recordId='
			+ EXLTA_recordId(element)},true);
	EXLTA_addTab('QViewOnline','QViewOnlineTab','NONE', qViewOnlineTabHandler, false, emptyFunction);
} //end prepareQViewOnlineTab() 

function prepareQTocTab(){
	var emptyFunction = function(){return true;};
	var qViewOnlineTabHandler =
		EXLTA_createWidgetTabHandler(function(element){return '<iframe src=/primo_library/libweb/csids/tiles/toc_tab.jsp?recordId='
			+ EXLTA_recordId(element)},true);
	EXLTA_addTab('QToc','QTocTab','NONE', qViewOnlineTabHandler, false, emptyFunction);
} //end prepareQTocTab() 

//The function prepareQILLTab() is by OUHK LIB QSYS (William NG) for preparing to display multi-volume ILL request tab. Dated 11 Oct 2016.
function prepareQILLTab(){
	var emptyFunction = function(){return true;};
	var qILLTabHandler =
		EXLTA_createWidgetTabHandler(function(element){return '<iframe src=/primo_library/libweb/csids/tiles/ill_form_multi.jsp?recordId='
			+ EXLTA_recordId(element)
			//<lds46> <lds47> and <lds48> are Primo PNX local defined tags for ILL requests.
			// The values are now gotten from calling the fucntion EXLTA_XXX from EXLTabAPI.03b_modified.js.
		 	+ '&lds46=' + EXLTA_lds46(EXLTA_recordId(element))
		 	+ '&lds47=' + EXLTA_lds47(EXLTA_recordId(element))
		 	+ '&lds48=' + EXLTA_lds48(EXLTA_recordId(element))
		},true);
	EXLTA_addTab('QILL','QILLTab','NONE', qILLTabHandler, false, emptyFunction);
} //end prepareQILLTab() 

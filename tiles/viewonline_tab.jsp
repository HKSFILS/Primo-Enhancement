<%-- 
 README:
	Version 1.3
	By William NG (OUHK LIB QSYS).  Dated: 18 Oct 2016. 
	This JSP script (viewonline_tab.jsp) is written to replace the default Primo View Online Tab for better display.
	This script is called when the customized "View Online" Tab (CSS class "QViewOnlineTab") is clicked.
	This script accepts a primo record id then uses Javascript codes to fetch all the <linktosrc> by record ID given,
	for doing so, "EXLTabAPI.03b_modified.js" and "jquery-1.11.3.js" is employed.
	Eventually, URLs of the titles will be displayed.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Load core Primo JSTL. --%>
<%@ include file="/views/taglibsIncludeAll.jspf" %>

<%-- Retrive CSIDS Primo Customized Code Table codes and environment varialbes. (see the JSP's source codes for descriptions.) --%>
<%@ include file="/csids/tiles/loadPrimoCodeTables.jsp"%>

<%-- Load core CSIDS functions. --%>
<%@ include file="/csids/tiles/csids.jsp"%>

<%-- Load core CSIDS css for display. --%>
<link rel="stylesheet" type="text/css" href="/primo_library/libweb/csids/css/csids.css">

<%
	//JSTLs sfxWording, sysSourceID, and consortialMembersStr are obtained from loadPrimoCodeTables.jsp. 
	HashMap<String,String> sfxWording = (HashMap<String,String>) pageContext.getAttribute("sfxWording");
	HashMap<String,String> sysSourceID = (HashMap<String,String>) pageContext.getAttribute("sysSourceID");
	String instsStr = pageContext.getAttribute("consortialMembersStr").toString();

	String[] insts = instsStr.split(",");
	String recordId = request.getParameter("recordId");
	recordId = recordId.replace("</div", "");

%>

<%-- Read wordings from Primo Code Table for Viewonline Tab links wordings standardlization.--%>
<fmt:message key="getit.customized.viewonline_wording_convertion" var="wordingConvertion"/>
<c:set var="wordingsConvertion" value="${fn:split(wordingConvertion, ',')}"/>
<fmt:message key="getit.customized.viewonline_wording_removal" var="wordingRemoval"/>
<c:set var="wordingsRemoval" value="${fn:split(wordingRemoval, ',')}"/>

<html>
<head>

<%-- Load necessary JavaScript functions --%>
<script type="text/javascript" src="/primo_library/libweb/csids/javascript/csids.js"></script>
<script type="text/javascript" src="/primo_library/libweb/csids/javascript/EXLTabAPI.03b_modified.js"></script>
<script type="text/javascript" src="/primo_library/libweb/csids/javascript/jquery-1.11.3.js"></script>

<style>
.EXLViewOnlineTabContent {overflow:n;overflow-x:hidden;}
</style>
<script language="javascript" type="text/javascript">

//JavaScript function for dispalying e-resources' links for a title. JSTL & JSP are used in amid to generate the JavaScript.
function loadLinks(){

	//Get Primo PNX record via the function EXLTA_getPNX() whihc is contained in EXLTabAPI.03b_modified.js. 
	var recordId = '<%=recordId%>';
	var pnx = EXLTA_getPNX(recordId);

	var otherInnerHTML = "";
	var homeLibHold = false;
	var otherLibHold = false;
	var homeLibCode = '${sessionScope.institutionCode}';
	var institutionHTML = "";
	var homeAvailableRSC = '<b>  <fmt:message key="ovl.customized.homeAvailableRSC"/> </b>';
	var otherAvailableRSC = '<b> <fmt:message key="ovl.customized.otherAvailableRSC"/> </b>';
	var viewOnlineVia = '<fmt:message key="ovl.customized.viewOnlineVia"/>';
	if(!homeAvailableRSC){
		homeAvailableRSC = "Available for Home Institution Users";
	} //end if
	if(!otherAvailableRSC){
		otherAvailableRSC = "Available for Other Institution Users";
	} //end if
	if(!viewOnlineVia){
		viewOnlineVia = "View online via: ";
	} //end if
	var institutions = [
<%
	//Print to JavaScript an the array "institutions" Institute code to ILS ID mapping. E.g. {"OUL01", "OUHK"}.
	Iterator it = sysSourceID.entrySet().iterator();
	out.print("\t\t");
	while (it.hasNext()) {
        	Map.Entry pair = (Map.Entry)it.next();
	        out.print("'" + pair.getValue() + "','" + pair.getKey() +"',");
	} //end while
%>
	];

	//Read PNX <display><linktosrc> the URLs of an e-title, transform the links then display. 
	setTimeout(function() {
		var linktosrcs = $(pnx).find('linktorsrc');
		var srcs = $(pnx).find('source');
		var lklength = linktosrcs.length;
		var innerHTML = '';
		for (var i = 0; i < lklength; i++) {
        		var linktosrc = $(pnx).find('linktorsrc').eq(i).text();
			srclink = linktosrc.match(/\$\$U(.*)/);
			srclink[1] = srclink[1].replace(/\$\$D.*/, '');
			srclink[1] = srclink[1].replace(/\$\$E.*/, '');
			var institution = 'NA';

			if (linktosrc.match(/\\$\\$Ocsids(.*)/)) {
				institution = linktosrc.match(/\$\$O(.*)/);
				institution = institution[1];
				institution = institution.replace(/\$\$O/, '');
			} // endif

			for(var j=1; j<institutions.length; j=j+2){
				if(linktosrc.indexOf(institutions[j]) > -1){
					institution = institutions[j];
				} //end if
			} //end for

			if (institution.indexOf('NA') > -1) {
				institution = $(pnx).find('source').eq(i).text();
			} //end if

			for (var j = 0; j < institutions.length - 1; j = j + 2) {
				if (institution.indexOf(institutions[j]) > -1) {
					institution = institutions[j + 1];
				} //end if
			} // end for
			var description = '';
			var descriptionsArry = [];
			if (linktosrc.match(/\$\$D(.*)/)) {
				description = linktosrc.match(/\$\$D(.*)/);
				description = description[1];
				description = description.replace(/\$\$.*/, '');
				if (description.indexOf('DUMMY') > -1) {
					description = '';
					continue;
				} //end if
				description = description.replace(/\&nbsp;/g, " ");

<%
	for(int i=0; i<insts.length; i++){
		out.println("description = description.replace(/" + insts[i] + "/, \"\");");
	} //end for
%>

<%-- Doing Viewonline links wording removal and conversion via client side Javascript. --%>
<c:forEach var="wordingItem" items="${wordingRemoval}">
				description = description.replace(/${wordingItem}/g, "");
</c:forEach>
<c:forEach var="wordingItem" items="${wordingsConvertion}">
				description = description.replace(/${wordingItem}/g, viewOnlineVia);
</c:forEach>


				description = ' &nbsp; &nbsp; - <span class="EXLViewOnlineLinksTitle">' + '<a href=' + srclink[1] + ' target="_blank">'
					 + description + ' ('  + institution +  ')</a> &nbsp; &nbsp; &nbsp; <br>' + ' </span>';
			} // end if

			if (!description) {
				description = ' &nbsp; &nbsp; - <span class="EXLViewOnlineLinksTitle">'
					 + '<a href=' + srclink[1] + ' target="_blank"> ' + viewOnlineVia + '</span>';
				description += ' (' + institution + ') </a> &nbsp; &nbsp; <br>';
			} //end if
			if(institution == homeLibCode && homeLibHold==false){
				homeLibHold=true;
				innerHTML = homeAvailableRSC + "<br>" + description + innerHTML + "<br>";
<%
	//Convert SFX wording. E.g. OUHK uses "FINDIt" instead of "SFX".
	for(int i=0; i<insts.length; i++){
		if(sfxWording.get(insts[i]) != null){
			out.print("\t\t");
			out.print("\t\t");
			out.println("if(institution.indexOf('" + insts[i] + "') > -1){");
			out.print("\t\t");
			out.print("\t\t");
			out.print("\t\t");
			out.println("innerHTML = innerHTML.replace(\"SFX\", \"" + sfxWording.get(insts[i]) + "\");");
			out.print("\t\t");
			out.print("\t\t");
			out.println("}");
		} //end if
	} //end for
%>
			} else if (institution == homeLibCode && homeLibHold){
				innerHTML = innerHTML.replace(homeAvailableRSC, homeAvailableRSC + "<br>" + description);
				innerHTML = innerHTML.replace("<br> </span><br>", "</span><br>");
			} else { 
				otherLibHold=true;
				otherInnerHTML += description;
			} //end if
		} //end for
		if(otherLibHold){
			innerHTML += otherAvailableRSC + " <br>" + otherInnerHTML;
		} //end if
		if(innerHTML == ""){
			innerHTML = "Err: no record found. RecID: " + recordId;
		} //end if
		document.getElementById('links').innerHTML = innerHTML;
	}, 500);
} //end loadLinks()
</script>
<title>Cogito, Ergo Sum.</title>
</head>
<body>
<div class="EXLViewOnlineTabContent"> 
<div class="EXLViewOnlineLinks">
<font size=2>
<div id="links"> <fmt:message key="ovl.customized.loading"/> </div>
</font>
</div>
</div>
<script language="javascript" type="text/javascript">
	window.onload=loadLinks();
</script>
</body>
</html> 

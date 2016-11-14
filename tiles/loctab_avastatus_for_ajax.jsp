<%--
README:
	William NG (OUHK LIB QSYS).
	Version 1.1 (Dated 13 Oct 2016)
	This JSP script loctab_avastatus_for_ajax.jsp is called by loctab_avastatus_call_ajax.jsp to display Location Tab RTA info.
	Tis script accepts record ID, library code, and sublibrary as paramaters.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Load core Primo JSTL. --%>
<%@ include file="/views/taglibsIncludeAll.jspf" %>

<%-- Load core CSIDS functions. --%>
<%@ include file="/csids/tiles/csids.jsp"%>

<%-- Retrive CSIDS Primo Customized Code Table codes and environment varialbes. (see the jsp source codes for descriptions. --%>
<%@ include file="/csids/tiles/loadPrimoCodeTables.jsp"%>

<c:set var="avastatus" value="" />
<c:set var="recid" value="" />
<%
	//JSTL tags locRTABaseURL & ilsLibraryID are from loadPrimoCodeTables.jsp.
        HashMap<String,String> locRTABaseURL = (HashMap<String,String>) pageContext.getAttribute("locRTABaseURL");
        HashMap<String,String> ilsLibraryID = (HashMap<String,String>) pageContext.getAttribute("ilsLibraryID");

	
	String recid = request.getParameter("recid");
	String lib = request.getParameter("lib");
	String subLib = request.getParameter("subLib");

	String inst = "";
	//Check from the ILS record ID and convert the ID from source ILS code to institute's code (e.g. from OUL01 to OUHK)
	Iterator it = ilsLibraryID.entrySet().iterator();
	while (it.hasNext()) {
		Map.Entry pair = (Map.Entry)it.next();
		String key = pair.getKey().toString();
		key = normalizeString(key);
		String value = (String) pair.getValue();
		String ilsIDCode = value.substring(0,3);
		if(recid.contains(ilsIDCode) || recid.contains(value) || recid.matches(value) ){
			inst = key;
			if(recid.contains(ilsIDCode))
				recid = recid.replaceAll(value, "");
			recid = key + "-" + recid;
			recid += "-BOOK";
			break;
		} //end if 
	} //end while
	String avaStatus = "";
	try{
		//checkLocationTabAVAStatus fetches RTA info for Location Tab; and is in csids.jsp.
		avaStatus = checkLocationTabAVAStatus(recid, subLib, locRTABaseURL.get(inst));
	} //end try
	catch(Exception ex){pageContext.setAttribute("avastatus", ex.toString());}
	pageContext.setAttribute("avastatus", avaStatus.toString());
%>

<%-- Show the availbility. --%>
<c:choose>
	<c:when test="${avastatus == 'AVAILABLE'}">
		<em class="EXLResultStatusAvailable">
			 <fmt:message key="fulldisplay.availabilty.available"/> 
	</c:when>
	<c:when test="${avastatus == 'UNAVAILABLE'}">
		<em class="EXLResultStatusNotAvailable">
			 <fmt:message key="fulldisplay.availabilty.unavailable"/>
	</c:when>
	<c:when test="${avastatus == 'MAYBEAVAILABLE'}">
		<em class="EXLResultStatusMaybeAvailable">
			 <fmt:message key="fulldisplay.availabilty.check_holdings"/>
	</c:when>
	<c:otherwise>
	${avastatus}
	</c:otherwise>
</c:choose>

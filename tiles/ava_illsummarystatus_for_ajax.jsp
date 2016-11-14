<%--
 README:
 Ver. 1.3
 Dated: 3 Oct 2016
 By William NG (OUHK LIB QSYS)
 This file ava_illsummarystatus_for_ajax.jsp checks if a title is lendable (NOT in special statuses like "checked out", "in process"...).
 The ILL tab will show if only of this is the case.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/views/taglibsIncludeAll.jspf" %>

<%-- Retrive CSIDS Primo Customized Code Table codes and environment varialbes. (see the jsp source codes for descriptions.) --%>
<%@ include file="/csids/tiles/loadPrimoCodeTables.jsp"%>
<%-- Load CSIDS core functions. --%>
<%@ include file="/csids/tiles/csids.jsp"%>

<c:set var="avaresult" value="" />

<%
	//JSTL tags rtaBaseURL & avaStatuses are from loadPrimoCodeTables.jsp.
	HashMap<String,String> rtaBaseURL = (HashMap<String,String>) pageContext.getAttribute("rtaBaseURL");
	HashMap<String,String[]> avaStatuses = (HashMap<String,String[]>) pageContext.getAttribute("avaStatuses");

	String recordIdsStr = request.getParameter("recordIds");
	String[] recids = recordIdsStr.split(",");
	String[] avaes = recids;
	String avastatuses_str = "";

	//Determine which institute hold the ILL requested title by ILS source record IDs and query the source ILS for availbility.
	try{
		for(int i=0; i<recids.length; i++){
			String inst = recids[i].split("-")[0];
			//checkAVAStatus() is from csids.jsp
			avaes[i] = checkAVAStatus(recids[i],rtaBaseURL.get(inst),avaStatuses);
			avastatuses_str += avaes[i] + ",";
		} //end for
	} //end try
	catch(Exception ex){out.println(ex.toString());}

	//Returning the availbility checking results to ava_illsummarystatus_for_ajax.jsp. 
	out.println(avastatuses_str);
%>

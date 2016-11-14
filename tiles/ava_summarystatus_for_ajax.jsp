<%--
 README:
	Ver. 1.3
	By William NG (OUHK LIB QSYS) Dated: 19 Oct 2016.
	This JSP script ava_summarystatus_for_ajax.jsp accepts parameter of a string of multiple record IDs and return a calculated summary status.
	This script is called by ava_summarystatus_call_ajax.jsp via Javascript. See ava_summarystatus_call_ajax.jsp's read-me for its relations to other JSP files.
	This script uses csids.jsp which contains functions for checking real time availbility and computing a summary status.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Load core Primo JSTL. --%>
<%@ include file="/views/taglibsIncludeAll.jspf" %>

<%-- Retrive CSIDS Primo Customized Code Table codes and environment varialbes. (see the JSP's source codes for descriptions.) --%>
<%@ include file="/csids/tiles/loadPrimoCodeTables.jsp"%>

<%-- Load core CSIDS functions. --%>
<%@ include file="/csids/tiles/csids.jsp"%>

<c:set var="avasummary" value="" />
<%
	//JSTLs rtaBaseURL and avaStatuses are obtained from loadPrimoCodeTables.jsp.
	HashMap<String,String> rtaBaseURL = (HashMap<String,String>) pageContext.getAttribute("rtaBaseURL");
	HashMap<String,String[]> avaStatuses = (HashMap<String,String[]>) pageContext.getAttribute("avaStatuses");

	String recordIdsStr = request.getParameter("recordIds");
	String homeLib = request.getParameter("homeLib");
	String[] recids = recordIdsStr.split(",");
	String[] avaes = new String[recids.length];
	String avaSummary = "SUMMARY";
	try{
		//For each record ID associated with the title, check real time availbility of the item with the record ID
		for(int i=0; i<recids.length; i++){
			String inst = recids[i].split("-")[0];
			avaes[i] = checkAVAStatus(recids[i], rtaBaseURL.get(inst), avaStatuses);
		} //end for
		//Compute summary status codes by giving the result availbility statutes as an array.
		avaSummary = calculateAVASummary(recids, avaes, homeLib);
	} //end try
	//If any exception happens, print out the the end users.
	catch(Exception ex){out.println(ex.toString());}
	pageContext.setAttribute("avasummary", avaSummary);
	pageContext.setAttribute("avas", avaes);
	pageContext.setAttribute("recs", recids);
%>


<c:set var="avasummaries" value="${fn:split(avasummary, ',')}" />
<c:set var="resultStatusClass" value=""/>
<c:set var="tmpleng" value="${fn:length(avasummaries)}" />
<c:set var="ava_summary_textSet" value="false"/>
<c:set var="reachable" value="false"/>

<%-- Decode the summary status(es) with the Primo Code table "Calculated Availability Text" for showing to the end-users.--%>
<%-- The codes 1 to 49 is defined in csids.jsp and are used between scripts internally only. --%>
<c:forEach var="i" begin="0" end="${fn:length(avasummaries)}" step="1">
	<c:choose>
		<c:when test="${avasummaries[i] == '1'}">
			<fmt:message key="delivery.customized.code.ebookOnOrderHome" var="ava_summary_text"/>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
		</c:when>
		<c:when test="${avasummaries[i] == '2'}">
			<fmt:message key="delivery.customized.code.ebookInProcessHome" var="ava_summary_text"/>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
		</c:when>
		<c:when test="${avasummaries[i] == '3'}">
			<fmt:message key="delivery.customized.code.onlineAccessHomeAndOther" var="ava_summary_text"/>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusAvailable"/>
			<c:set var="reachable" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '4'}">
			<fmt:message key="delivery.customized.code.onlineAccessHome" var="ava_summary_text"/>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusAvailable"/>
			<c:set var="reachable" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '5'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.ebookOnOrderOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.ebookOnOrderOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
		</c:when>
		<c:when test="${avasummaries[i] == '6'}">
			<fmt:message key="delivery.customized.code.ebookInProcessOther" var="ava_summary_text"/>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
		</c:when>
		<c:when test="${avasummaries[i] == '7'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.onlineAccessOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.onlineAccessOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="reachable" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
		</c:when>
		<c:when test="${avasummaries[i] == '8'}">
			<c:set var="tmp" value=""/>
			<fmt:message key="delivery.customized.code.andOther" var="tmp"/>
			<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			<c:set var="ava_summary_textSet" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '20'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.availableHome" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.availableHome" var="ava_summary_text"/>
			</c:if>
			<c:set var="resultStatusClass" value="EXLResultStatusAvailable"/>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="reachable" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '21'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.checkedOutHome" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.checkedOutHome" var="ava_summary_text"/>
			</c:if>
			<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			<c:set var="ava_summary_textSet" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '22'}">
			<fmt:message key="delivery.customized.code.onOrderHome" var="ava_summary_text"/>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
		</c:when>
		<c:when test="${avasummaries[i] == '23'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.inProcessHome" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.inProcessHome" var="ava_summary_text"/>
			</c:if>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '24'}">
			<fmt:message key="delivery.customized.code.onOrderCancelledHome" var="ava_summary_text"/>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
		</c:when>
		<c:when test="${avasummaries[i] == '29'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.onDisplayHome" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.onDisplayHome" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
		</c:when>
		<c:when test="${avasummaries[i] == '30'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.libraryUseOnlyHomeAndOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.libraryUseOnlyHomeAndOther" var="ava_summary_text"/>
			</c:if>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusAvailable"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '40'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.availableOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.availableOther" var="ava_summary_text"/>
			</c:if>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusMaybeAvailable"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '41'}">
			<c:set var="tmp" value=""/>
			<fmt:message key="delivery.customized.code.andOther" var="ava_summary_text"/>
			<c:set var="ava_summary_textSet" value="true"/>
		</c:when>

		<c:when test="${avasummaries[i] == '42'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.checkedOutOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.checkedOutOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
		</c:when>
		<c:when test="${avasummaries[i] == '43'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.onOrderOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.onOrderOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
		</c:when>
		<c:when test="${avasummaries[i] == '44'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.inProcessOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.inProcessOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
		</c:when>
		<c:when test="${avasummaries[i] == '45'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.libraryUseOnlyOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.libraryUseOnlyOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
		</c:when>
		<c:when test="${avasummaries[i] == '46'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.onOrderCancelledOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.onOrderCancelledOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
		</c:when>
		<c:when test="${avasummaries[i] == '47'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.missingOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.missingOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
		</c:when>
		<c:when test="${avasummaries[i] == '48'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.partlyAvailableOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.partlyAvailableOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusMaybeAvailable"/>
			</c:if>
		</c:when>
		<c:when test="${avasummaries[i] == '49'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.onDisplayOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.onDisplayOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '28'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.availableHomeAndOther" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.availableHomeAndOther" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusAvailable"/>
			<c:set var="reachable" value="true"/>
		</c:when>
		<c:when test="${avasummaries[i] == '26'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.partlyAvailableHome" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="delivery.customized.code.partlyAvailableHome" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusMaybeAvailable"/>
			</c:if>
		</c:when>
		<c:when test="${avasummaries[i] == '27'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="default.delivery.customized.code.libraryUseOnlyHome" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="default.delivery.customized.code.libraryUseOnlyHome" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:set var="resultStatusClass" value="EXLResultStatusMaybeAvailable"/>
		</c:when>
		<c:when test="${avasummaries[i] == '25'}">
			<c:if test="${ava_summary_textSet}">
				<c:set var="tmp" value=""/>
				<fmt:message key="delivery.customized.code.missingHome" var="tmp"/>
				<c:set var="ava_summary_text" value="${ava_summary_text} ${tmp}"/>
			</c:if>
			<c:if test="${not ava_summary_textSet}">
				<fmt:message key="default.delivery.customized.code.missingHome" var="ava_summary_text"/>
			</c:if>
			<c:set var="ava_summary_textSet" value="true"/>
			<c:if test="${not reachable}">
				<c:set var="resultStatusClass" value="EXLResultStatusNotAvailable"/>
			</c:if>
		</c:when>
	</c:choose>
</c:forEach>

<%-- Print out the result summary status. The result will be obtained and dynamically updated  by ava_summarystatus_call_ajax.jsp. --%>
<p class="EXLResultAvailability">
<div id="ava_summary_text">
<em class="${resultStatusClass}" id="RTADivTitle_${resultStatus.index}">
${ava_summary_text} 
</em>
</div>
</p>

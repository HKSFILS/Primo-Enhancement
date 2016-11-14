<%--
 README:
	Ver. 1.2
	By William NG (OUHK LIB QSYS). Dated: 19 Oct 2016.
	This script ava_summarystatus_call_ajax.jsp is called by resultsTile.jsp or fullRecord.jsp to gether RTA summary status.
	This script gathers each title Primo record IDs and calls ava_summarystatus_for_ajax.jsp by Javascript AJAX.
	The record IDs are contained in PNX <display> <lds47>
	After the RTA summary status is gathered, a <div> tag with the id ava_summary_text for RTA summary status is udpated by Javascript.
--%>

<%-- Retrive CSIDS Primo Customized Code Table codes and environment varialbes. (see the JSP's source codes for descriptions.) --%>
<%@ include file="/csids/tiles/loadPrimoCodeTables.jsp"%>

<%-- 
        Test if the current Primo Search Tab in use is the institution's Union Search Code.
        The cutomized View Online Tab will show only if this is the case
        - i.e. if currently the user is using individual catalog, the cutomized View Online Tab WON'T show.
                  The idea of testing current Primo Search Tab is from Paul CHIU (HKSYU LIB SYS); a credit must go to him.

        In Union Search setting, there is no current Primo Tab (request.getParameter("tab") will return null) be got when  viewing Primo full record on "e-Shelf".
        For entertaining the cases, record source ID is checked if it contains 'csids' which means this is a Union Search record.
	All the context variables are loaded from loadPrimoCodeTables.jsp.
 --%>
<c:if test="${urltab==unionsearch_tabcode or fn:contains(recordsource, 'csids')}">
	<c:set var="homeLib" value="${sessionScope.institutionCode}" />
	<c:set var="avastatuses" value="${fn:split('1,2,3,4,5,6,7,8,9,10', ',')}"/>
	<c:set var="ava_summary_text" value=""/>
	<c:set var="avastatuses_str" value="" />
	<c:set var="recids_str" value=""/>
		
	<c:if test="${fn:length(result.values.lds47) != 0}">
		<c:forEach var="i" begin="0" end="${fn:length(result.values.lds47) - 1}" step="1">
			<c:set var="inst_recid" value="${result.values.lds47[i]}" />
        	        <c:forEach var="j" begin="0" end="${fn:length(eResourceWordings) - 1}" step="1">
	                        <c:if test="${fn:contains(fn:toUpperCase(inst_recid), fn:toUpperCase(eResourceWordings[j]) )}">
					<c:set var="inst_recid" value="${inst_recid}-WBA"/>
                	        </c:if>
        	        </c:forEach>
        	        <c:forEach var="j" begin="0" end="${fn:length(inprocessWordings) - 1}" step="1">
	                        <c:if test="${fn:contains(fn:toUpperCase(inst_recid), fn:toUpperCase(inprocessWordings[j]) )}">
					<c:set var="inst_recid" value="${inst_recid}-IPO"/>
                        	        <c:set var="webaccessible" value="false"/>
                	        </c:if>
        	        </c:forEach>
        	        <c:forEach var="j" begin="0" end="${fn:length(physicalWordings) - 1}" step="1">
	                        <c:if test="${fn:contains(fn:toUpperCase(inst_recid), fn:toUpperCase(physicalWordings[j]) )}">
					<c:set var="inst_recid" value="${inst_recid}-PHY"/>
                	        </c:if>
        	        </c:forEach>
			<c:if test="${i == 0}">
				<c:set var="recids_str" value="${inst_recid}" />
			</c:if>
			<c:if test="${i > 0}">
				<c:set var="recids_str" value="${recids_str},${inst_recid}" />
			</c:if>
		</c:forEach>
	</c:if>
	<p class="EXLResultAvailability">
	<div id="ava_summary_text${resultStatus.index}">
	<em class="${resultStatusClass}" id="RTADivTitle_${resultStatus.index}">
	<fmt:message key="ovl.customized.loading"/>
	</em>
	</div>
	</p>
	
	<script lanuage="javascript">
		var xhttp${resultStatus.index} = new XMLHttpRequest();
		xhttp${resultStatus.index}.onreadystatechange = function() {
			if (xhttp${resultStatus.index}.readyState == 4 && xhttp${resultStatus.index}.status == 200) {
				document.getElementById("ava_summary_text${resultStatus.index}").innerHTML = xhttp${resultStatus.index}.responseText;
			} //end if
		} //end function();
		// Call "ava_summarystatus_for_ajax.jsp" via AJAX.
		xhttp${resultStatus.index}.open("GET", "/primo_library/libweb/csids/tiles/ava_summarystatus_for_ajax.jsp?recordIds=${recids_str}&homeLib=${homeLib}", true);
		xhttp${resultStatus.index}.send();
	</script>
</c:if>

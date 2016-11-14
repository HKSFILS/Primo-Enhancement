<%--
 README:
 Ver. 1.3
 Dated: 3 Oct 2016
 By William NG (OUHK LIB QSYS)
 This file ava_illsummarystatus_call_ajax.jsp calls ava_illsummarystatus_for_ajax.jsp.
 ava_illsummarystatus_call_ajax.jsp and ava_illsummarystatus_for_ajax.jsp togeth check if a title is lendable (NOT in special statuses like "checked out", "in process"...).
 The ILL tab will show only if the physical item is ready for ILL lending.
--%>

<c:set var="avastatuses" value="${fn:split('1,2,3,4,5,6,7,8,9,10', ',')}"/>
<c:set var="ava_summary_text" value=""/>
<c:set var="avastatuses_str" value="" />
<c:set var="webaccessible" value="false" />
<c:set var="recids_str" value=""/>

<c:if test="${fn:length(result.values.format) != 0}">
<c:forEach var="i" begin="0" end="${fn:length(result.values.format) - 1}" step="1">
	<c:forEach var="item" items="${eResourceWordings}">
		<c:if test="${fn:contains(fn:toUpperCase(result.values.format[i]), fn:toUpperCase(item) )}">
			<c:set var="webaccessible" value="true" />
		</c:if>
	</c:forEach>
</c:forEach>
</c:if>

<%-- Prepare recids_str, which contains a series of record IDs of institutes' ILS records (seperated by ',')
	 and will be passed to ava_illsummarystatus_for_ajax.jsp for checking. --%>
<%-- ILL requested title IDs are obtained from Primo PNX <display><lds47> in form [Institute]-[ILS Source Record ID]-[Material Type]. --%>
<c:if test="${fn:length(result.values.lds47) != 0}">
	<c:forEach var="i" begin="0" end="${fn:length(result.values.lds47) - 1}" step="1">
		<c:set var="inst_recid" value="${result.values.lds47[i]}" />

		<%-- Determine if the current title is only of web item.--%>
		<c:forEach var="item" items="${eResourceWordings}">
			<c:if test="${fn:contains(fn:toUpperCase(inst_recid), fn:toUpperCase(item) )}">
				<c:set var="webaccessible" value="true" />
			</c:if>
		</c:forEach>
		<c:forEach var="item" items="${physicalWordings}">
			<c:if test="${fn:contains(fn:toUpperCase(inst_recid), fn:toUpperCase(item) )}">
				<c:set var="webaccessible" value="false" />
			</c:if>
		</c:forEach>

		<%-- Only physical itme be ILL-requested. Web item cannot do ILL. --%>
		<c:if test="${not webaccessible}">
			<c:if test="${i == 0}">
				<c:set var="recids_str" value="${inst_recid}" />
			</c:if>
			<c:if test="${i > 0}">
				<c:set var="recids_str" value="${recids_str},${inst_recid}" />
			</c:if>
		</c:if>
	</c:forEach>
</c:if>
<%-- Using JavaScript AJAX to call ava_illsummarystatus_for_ajax.jsp for saving server respond time.
	That allows search result titles show first to end users first, then invoke the ILL request titles' avaibility.  --%>
<script lanuage="javascript">
	var xhttpillava${resultStatus.index} = new XMLHttpRequest();
	var ava_results;
	var recids_str = "${recids_str}";
	var recids${resultStatus.index}  = recids_str.split(",");
	xhttpillava${resultStatus.index}.onreadystatechange = function() {
		if (xhttpillava${resultStatus.index}.readyState == 4 && xhttpillava${resultStatus.index}.status == 200) {
			var response_text = xhttpillava${resultStatus.index}.responseText;
			ava_results= response_text.split(",");
			var result = "";
			for(i=0; i<recids${resultStatus.index}.length; i++){
				var instid${resultStatus.index} = recids${resultStatus.index}[i].split("-")[0];
				var ava = ava_results[i];
				ava = ava.replace('<!-- taglibsIncludeAll.jspf begin -->', '');
				ava = ava.replace('<!-- taglibsIncludeAll.jspf end -->', '');
				if( ava.indexOf("AVAILABLE") >=0 && ava.indexOf("NOILL") <= 0){
					result += instid${resultStatus.index} + "(AVA); ";
					document.getElementById("QResult${resultStatus.index}-ILLTab").style.display = "inline";
				} else {
					result += instid${resultStatus.index} + "(UNAVA); ";			
				} //end if
			} //end for
			var inputvalue = document.getElementById("ill_source${resultStatus.index}").value;
			document.getElementById("ill_source${resultStatus.index}").value
				 = inputvalue.replace("LOADING", result);
		} //end if
	} //end function();

	var url = "/primo_library/libweb/csids/tiles/ava_illsummarystatus_for_ajax.jsp?recordIds=${recids_str}";
	xhttpillava${resultStatus.index}.open("GET", url, true);
	xhttpillava${resultStatus.index}.send();
</script>

<%--
 README:
 by William NG (OU LIB QESS)
 Dated: 5 Aug 2016
 This JSP perform Primo Location Tab Real time availbility checking; and is to be included by:

/exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/views/full/tabs/locations_tile.jsp 

 loctab_avastatus_for_ajax.jsp is called by this script via AJAXfor getting the RTA.
--%>

<c:set var="avastatus_id" value="${result.ilsApiId}${result.library}${result.mainLocations}"/>
<c:set var="avastatus_id" value="${fn:replace(avastatus_id, '-', '')}"/>

<%-- This <div> will be updated dynamically after called loctab_avastatus_for_ajax.jsp. --%>
<div id="${avastatus_id}">
	<fmt:message key="ovl.customized.loading"/>
</div>

<script lanuage="javascript">
	var xhttp${avastatus_id} = new XMLHttpRequest();
	xhttp${avastatus_id}.onreadystatechange = function() {
		if (xhttp${avastatus_id}.readyState == 4
			&& xhttp${avastatus_id}.status == 200) {
				document.getElementById("${avastatus_id}").innerHTML =
				xhttp${avastatus_id}.responseText;
		} //end if
	} //end function();
	xhttp${avastatus_id}.open("GET",
		"/primo_library/libweb/csids/tiles/loctab_avastatus_for_ajax.jsp?recid=${result.ilsApiId}&lib=${result.library}&subLib=${result.mainLocations}",
		 true);
	xhttp${avastatus_id}.send();
</script>

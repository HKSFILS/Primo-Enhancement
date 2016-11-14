<%--

README:
        Version 1.1 (Dated 19 Oct 2016)
        By William NG (OUHK LIB QSYS).
        This JSP script bookcover_call_ajax.jsp is called by resultTile.jsp;
	and it calls bookcover_for_ajax.jsp to fetch book cover images from multiple webistes in sequence.
--%>

<%-- Retrive CSIDS Primo Customized Code Table codes and environment varialbes. (see the JSP's source codes for descriptions.) --%>
<%@ include file="/csids/tiles/loadPrimoCodeTables.jsp"%>

<%-- Read the material type of the current title --%>
<c:set var="type" value="${result.values[c_value_fmticon]}"  />
<%
	// JSTL tag ilsToPrimoTypeMappings is from loadPrimoCodeTables.jsp.
	HashMap<String,String[]> ilsToPrimoTypeMappings = (HashMap<String,String[]>) pageContext.getAttribute("ilsToPrimoTypeMappings");

	String type = (String) pageContext.getAttribute("type");
	type = type.trim();

	//Convert ILS definied material types to material types that Primo has an icon for them.
	Iterator it = ilsToPrimoTypeMappings.entrySet().iterator();
	while (it.hasNext()) {
		Map.Entry pair = (Map.Entry)it.next();
		String key = pair.getKey().toString();
		String[] values = (String[]) pair.getValue();
		for(int j=0; j<values.length; j++){
			values[j] = values[j].trim();
			if(type.equals(values[j]))
				pageContext.setAttribute("type", key);
		} //end for
	} //end while	
%>

<c:set var="isbn" value="${result.values.isbn}" />
<c:set var="isbn_str" value="" />
<c:choose>
	<%--
		This code section is copied from resultsTile.jsp for displaying default material type icon;
		a default material type icon displays if no book cover image is found.
	--%>
	<c:when test="${not empty resultTitleUrl
		and searchForm.delivery[resultStatus.index].displayTitle
		and searchForm.resultTitleLinkType=='0'
		or not empty resultTitleUrl
		and searchForm.resultTitleLinkType!='0'}">

		<c:if test="${not empty result.values[c_value_frbrgroupid] and  result.values[c_value_frbrtype][0] eq 7}">
			<c:url var="resultTitleUrl" value="${resultTitleUrl}">
			<c:param name="frbrVersion" value="${sessionScope[result.id]}"/>
			</c:url>
		</c:if>
		<c:if test="${(searchForm.mode != null) &&(searchForm.mode eq 'BrowseSearch')}">
			<c:set var="BROWSE_SEARCH_TEXT" value="BROWSE_SEARCH_TEXT"/>
			<c:url var="resultTitleUrl" value="${resultTitleUrl}">
			<c:param name="searchTxt" value='${searchForm.values[BROWSE_SEARCH_TEXT]}'/>
			</c:url>
		</c:if>

		<c:set var="azJournalPopUp" value=""/>
		<c:if test="${form.alma}">
			<c:set var="azJournalPopUp" value="openWindow(this.href, this.target, 'top=100,left=50,width=600,height=500,resizable=1,scrollbars=1'); return false;"/>
		</c:if>
		<div class="bg_fix multipleCoverImageContainer EXLBriefResultsDisplayCoverImages ">
		<a href="${fn:escapeXml(resultTitleUrl)}" onclick="reportClick();${boomCall}reportBibTip('${result.id}');${azJournalPopUp}">
			<%-- The <img> display default icon image; a book cover image overrides this image by JavaScript if found. --%>
			<img id="QBookCover${resultStatus.index}" src="/primo_library/libweb/images/icon_${type}.png">
		</a>
		</div>
	</c:when>
	<c:otherwise>
		<div class="bg_fix multipleCoverImageContainer EXLBriefResultsDisplayCoverImages ">
			<img id="QBookCover${resultStatus.index}" src="/primo_library/libweb/images/icon_${type}.png">
		</div>
	</c:otherwise>
</c:choose>

<c:forEach var="i" begin="0" end="${fn:length(isbn)}" step="1">
	<c:if test="${isbn_str == ''}">
		<c:set var="isbn_str" value="${isbn[0]}" />
	</c:if>
	<c:if test="${isbn_str != ''}">
		<c:set var="isbn_str" value="${isbn_str},${isbn[i]}" />
	</c:if>
</c:forEach>

<script lanuage="javascript">

	<%-- The function searchBKCoverByISBN() using JavaScript AJAX to call bookcover_for_ajax.jsp, whcih fetches book cover image's URL, and update HTML via JavaScript to end users if found.--%>
	function searchBKCoverByISBN(){
		var xhttpbkcover${resultStatus.index} = new XMLHttpRequest();
		xhttpbkcover${resultStatus.index}.onreadystatechange = function() {
			if (xhttpbkcover${resultStatus.index}.readyState == 4 && xhttpbkcover${resultStatus.index}.status == 200) {
				var respondText = xhttpbkcover${resultStatus.index}.responseText;
				respondText = respondText.replace(/(?:\r\n|\r|\n)/g, '');
				respondText = respondText.replace("<!-- taglibsIncludeAll.jspf begin --><!-- taglibsIncludeAll.jspf end -->", "");
				if(respondText != ""){
					document.getElementById("QBookCover${resultStatus.index}").src = respondText;
					return true;
				} //end if
			} //end if
		} //end function();

		//Call bookcover_for_ajax.jsp which will get the URL of the current title's book cover image.
		var url = "/primo_library/libweb/csids/tiles/bookcover_for_ajax.jsp?isbn=" + "${isbn_str}";
		xhttpbkcover${resultStatus.index}.open("GET", url, true);
		xhttpbkcover${resultStatus.index}.send();
	} //end searchBKCoverByISBN()

	searchBKCoverByISBN();
</script>

<%--

README:
        By William NG (OUHK LIB QSYS).
        Version 1.0 (Dated 23 Feb 2016)
        This JSP script bookcover_call_ajax.jsp is called by resultTile.jsp;
	and it calls bookcover_for_ajax.jsp to fetch book cover images from multiple webistes in sequence.
--%>

<%--
	Translate customized material types to Primo default material type;
	the type will instruct to display default image if no book cover image is found.
--%>
<c:set var="type" value="${result.values[c_value_fmticon]}"  />
<c:set var="type" value="${fn:replace(type, 'ebook', 'book')}" />
<c:set var="type" value="${fn:replace(type, 'exam_paper', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'audiovisual', 'video')}" />
<c:set var="type" value="${fn:replace(type, 'dissertation', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'microform', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'teach_material', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'course_material', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'course_reading', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'thesis', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'score', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'ejournal', 'journal')}" />
<c:set var="type" value="${fn:replace(type, 'eresources', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'ebooks', 'book')}" />
<c:set var="type" value="${fn:replace(type, 'exam_papers', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'audiovisuals', 'video')}" />
<c:set var="type" value="${fn:replace(type, 'dissertations', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'microforms', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'teach_materials', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'course_materials', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'course_readings', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'thesises', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'scores', 'other')}" />
<c:set var="type" value="${fn:replace(type, 'ejournals', 'journal')}" />
<c:set var="type" value="${fn:replace(type, 'eresources', 'other')}" />

<c:set var="isbn" value="${result.values.isbn}" />
<c:set var="isbn_str" value="" />
<c:choose>
	<%--
		This code section is copied from resultsTile.jsp for displaying default material type icon;
		a default material type icon is display if no book cover image is found.
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
			<%-- The <img> display default icon image; a book cover image will be updated to display by JavaScript if found. --%>
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
	<%-- The function using JavaScript AJAX to call bookcover_for_ajax.jsp, whcih fetches book cover image, and update to end users if found.--%>
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
		var url = "/primo_library/libweb/ouhk/jsp/bookcover_for_ajax_ouhk.jsp?isbn=" + "${isbn_str}";
		xhttpbkcover${resultStatus.index}.open("GET", url, true);
		xhttpbkcover${resultStatus.index}.send();
	} //end searchBKCoverByISBN()

	searchBKCoverByISBN();
</script>

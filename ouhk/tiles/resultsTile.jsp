<%-- Load CSIDS customized Javascript/JSP. (by William NG (OUHK LIB QSYS). Dated: 26 Nov 2015) --%>
<script type="text/javascript" src="/primo_library/libweb/csids/javascript/csids.js"></script>
<script type="text/javascript" src="/primo_library/libweb/csids/javascript/EXLTabAPI.03b_modified.js"></script>
<%@ include file="/csids/tiles/csids.jsp"%>

<%@ page import="java.net.URLEncoder" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/views/taglibsIncludeAll.jspf" %>
<script type="text/javascript" src="../javascript/primo_boomerang.js"></script>
<noscript>This feature requires javascript</noscript>
<%@ taglib uri="/WEB-INF/tlds/exlibris-ajax.tld" prefix="eas" %>

      <table cellspacing="0" class="EXLResultsTable" id="exlidResultsTable" summary="description place holder">
        <!--hidden table headers-->
        <thead>
        <tr class="EXLHiddenCue">
          <th class="EXLResultNumber">Result Number</th>
          <th class="EXLThumbnail">Material Type</th>
          <th class="EXLMyShelfStar">Add to My Shelf Action</th>
          <th class="EXLSummary">Record Details and Options</th>
        </tr>
        </thead>
<tbody>
<c:set var="showRecommendTab" value="false"/>

<c:set var="extensionsService" value="${searchForm.callExtService}"/>

<c:set var="errorsInPage"><html:errors/></c:set>

<c:if test="${empty form.searchResult.results and empty errorsInPage}">
	<jsp:include page="../../general/resolveLocale.jsp"/>
	<c:set var="uri" value="${sessionScope.staticHTMLs.noResults}" />	
	<%@ include file="/views/include/includeStaticHTML.jspf"%>

</c:if>



<c:forEach items="${form.searchResult.results}" var="result" varStatus="resultStatus">

	<c:set var="resultId" value="${result.id}"/>
	<c:set var="resultNumber" value="${result.resultNumber}"/>
	<c:set var="resultStatusIndex" value="${resultStatus.index}"/>

	<c:set var="isFrbr" value="${not empty result.values[c_value_frbrgroupid] and result.values[c_value_frbrtype][0] eq 7}"/>
	<c:set var="useGenericRecord" value="${searchForm.frbrDisplay == 1}"/>
	<c:set var="isFrbrNewDisplay" value="${isFrbr and useGenericRecord and !result.remote and (form.alma!=null && !form.alma)}"/>

	<%@ include file="/tiles/titleLink.jspf" %>



 
<tr id="exlidResult${resultStatus.index}" class="EXLResult EXLResultMediaTYPE${result.values[c_value_fmticon]}">
  <td class="EXLResultNumber">
  	${result.resultNumber}
  <!-- boomerang -->
 <prm:boomerang id="icon_${resultStatus.index}"  boomForm="${searchForm}" pageId="brief"
	opId="icon" resultDoc="${searchForm.searchResult.results[resultStatus.index]}" type="title,${searchForm.delivery[resultStatus.index].titleLink}" delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${param.indx}"/>

 <prm:boomerang id="title_${resultStatus.index}"  boomForm="${searchForm}" pageId="brief"
	opId="title" resultDoc="${searchForm.searchResult.results[resultStatus.index]}" type="title,${searchForm.delivery[resultStatus.index].titleLink}" delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${param.indx}"/>
<c:set var="isOnline">false</c:set>
<c:if test="${searchForm.delivery[resultStatus.index].displayTitle and searchForm.resultTitleLinkType=='0'}">
		<c:set var="boomCall">boomCallToRum('title_${resultStatus.index}',false);</c:set>
		<c:set var="isOnline">true</c:set>
</c:if>
<!-- boomerang -->	
  </td>

	<c:set var="baseFrbrUrl" value="${form.responseEncodeReqDecUrl}"/>
	<c:if test="${!result.remote}">
		<!-- c:set var="baseFrbrUrl" value="${fn:replace(form.responseEncodeReqDecUrl,'srt','srt1')}"/ -->
		<c:set var="sortBy" value="${searchForm.frbrSortBy}"/>
	</c:if>
	<c:url var="frbrUrl" value="${baseFrbrUrl}">
		<c:param name="cs" value="frb"/>
		<c:param name="ct" value="frb"/>
		<c:param name="frbg" value="${result.values[c_value_frbrgroupid][0]}"/>
		<c:param name="fctN" value="${c_facet_frbrgroupid}"/>
	 	<c:param name="fctV" value="${result.values[c_value_frbrgroupid][0]}"/>
	 	<c:param name="doc" value="${result.id}"/>
	 	<c:param name="lastPag" value="${form.pag}"/>
	 	<c:param name="lastPagIndx" value="${param.indx}"/>
	 	<c:param name="rfnGrp" value="frbr"/>
	 	<c:if test="${!result.remote}">
	 		<c:param name="frbrSrt" value="${sortBy}"/>
	 	</c:if>
`	</c:url>

	<c:set var="titleSource"><prm:fields fields="${form.resultView[0]}" result="${result}" fieldDelims="${form.displayFieldsDelimiters[0]}"/></c:set>
	<c:set var="title" value="${fmt:escapeLooseAmpersands(titleSource)}" />

  	<!-- Use new display of frbr (generic record) -->
  	<c:if test="${isFrbrNewDisplay}">
		<td class="EXLThumbnail">
			<a name="${result.id}" id="${result.id}" class="EXLResultRecordId"></a>
			<c:if test="${form.alma != null && !form.alma}">
				<div class="multipleCoverImageContainer">
					<a target="_parent" href="${fn:escapeXml(frbrUrl)}" title="<fmt:message key='mediatype.multiplever'/>">
						<img src="../images/icon_versions.png" alt="<fmt:message key='mediatype.multiplever'/>"/>
					</a>
				</div>
		 		<div class="EXLHiddenCue">Material Type: </div><span class="EXLThumbnailCaption" id="mediaTypeCaption-${result.resultNumber}"><fmt:message key="mediatype.multiplever"/></span>
			</c:if>
		</td>
	  	<td class="EXLMyShelfStar"/>

		<td class="EXLSummary">
		  	<div class="EXLSummaryContainer">
	  			<div class="EXLSummaryFields">
		  			<h2 class="EXLResultTitle">
						<a id="titleLink" target="_parent" href="${fn:escapeXml(frbrUrl)}" onclick="reportClick();${boomCall}reportBibTip('${result.id}');${azJournalPopUp}">
		  					${title}
		  				</a>
		  			</h2>
					<c:set var="author"><prm:fields fields="creator,contributor" result="${result}" fieldDelims="${form.displayFieldsDelimiters[1]}"/></c:set>
					<c:if test="${not empty author}">
				    	<h3 class="EXLResultAuthor">${fmt:escapeLooseAmpersands(author)}</h3>
					</c:if>
					<span class="EXLResultVersionFound">
						<fmt:message key="frbrversion.found"/>
					</span>
					<h3 class="EXLResultSeeFrbrLink">
						<fmt:message key="frbrversion.see.link"/>
					</h3>
		  		</div>
                <c:set var="resultStatusIndex" value="${resultStatus.index}"/>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-viewOnlineTab" class="EXLResultTabContainer EXLContainer-viewOnlineTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-requestTab" class="EXLResultTabContainer EXLContainer-requestTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-locationsTab" class="EXLResultTabContainer EXLContainer-locationsTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-detailsTab" class="EXLResultTabContainer EXLContainer-detailsTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-tagreviewsTab" class="EXLResultTabContainer EXLContainer-tagreviewsTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-recommendTab" class="EXLResultTabContainer EXLContainer-recommendTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-moreTab" class="EXLResultTabContainer EXLContainer-moreTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-citationsTab" class="EXLResultTabContainer EXLContainer-citationsTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-browseshelfTab" class="EXLResultTabContainer EXLContainer-browseshelfTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-onlinereviewsTab" class="EXLResultTabContainer EXLContainer-onlinereviewsTab EXLResultTabContainerClosed">
		    </div>
				<cite class="EXLResultFRBR">
					<span class="EXLResultBgFRBR"></span>
						<a class="EXLBriefResultsDisplayMultipleLink" target="_parent" href="${fn:escapeXml(frbrUrl)}">${result.values[c_value_versions][0]}</a>
					<span class="EXLResultBgRtlFRBR"></span>
				</cite>
			</div>
			<br/>
		</td>
  	</c:if>

  <!-- Use old display of frbr (preferred record) -->
  <c:if test="${!isFrbrNewDisplay}">
	  <td class="EXLThumbnail"><a name="${result.id}" id="${result.id}" class="EXLResultRecordId"></a>
	  	<c:if test="${form.alma != null && !form.alma}">

<%-- Comment out the Primo default Book Cover codes (William NG (OUHK) dated: 1 Feb 2016)--%>
<%--
			<!--begin thumbnails-->
				<prm:thumbnails thumbLocation="display" thumbnailLinks="${form.delivery[resultStatus.index].thumbnailLinks}" index="${resultStatus.index}" resultTitleUrl="${resultTitleUrl}" displayURL="${displayURL}" isOnline="${isOnline}" displayTitle="${searchForm.delivery[resultStatus.index].displayTitle}"/>
		    <!--end thumbnails-->
--%>

<%-- Start of Customized Book Cover Icon codes (William NG (OUHK) dated: 8 Jan 2016)--%>
<%@ include file="/csids/tiles/bookcover_call_ajax.jsp"%>
<%-- End of Customized Book Cover Icon codes. --%>

		 	<div class="EXLHiddenCue">Material Type: </div><span class="EXLThumbnailCaption" id="mediaTypeCaption-${result.resultNumber}"><fmt:message key="mediatype.${result.values[c_value_fmticon]}" /></span>
	  	</c:if>
	  </td>
	  <td class="EXLMyShelfStar">
	 	<c:choose>
		 	<c:when test="${result.remote}">
		 		<prm:miniAddToEshelf basketIndex="${resultStatus.index}" recId="${result.id}" isRemote="${result.remote}" scopes="${form.scp.scps4remote}" resultIndex="${result.resultNumber}"/>
		 	</c:when>
		 	<c:otherwise>
				<prm:miniAddToEshelf basketIndex="${resultStatus.index}" recId="${result.values[c_value_recordid][0]}" isRemote="${result.remote}" scopes="" resultIndex="${result.resultNumber}"/>
			</c:otherwise>
	 	</c:choose>
	  </td>
	  <td class="EXLSummary">
		  <div class="EXLSummaryContainer">
			<div class="EXLSummaryFields">
				<h2 class="EXLResultTitle">
				<c:set var="strippedTitle">${fn:replace(fn:replace(title,'<span class="searchword">',''),'</span>','')}</c:set>
				<c:set var="linkTitleSuffix">-&nbsp;${resultStatus.index}</c:set>
				
				<!-- strippedTitle=${strippedTitle} -->
				<c:choose>
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
						<a href="${fn:escapeXml(resultTitleUrl)}" onclick="reportClick();${boomCall}reportBibTip('${result.id}');${azJournalPopUp}">${title}</a>
					</c:when>
					<c:otherwise>
						${title}
					</c:otherwise>
				</c:choose>
				</h2>
				<c:set var="author"><prm:fields fields="${form.resultView[1]}" result="${result}" fieldDelims="${form.displayFieldsDelimiters[1]}"/></c:set>
				<c:if test="${not empty author}">
			    	<h3 class="EXLResultAuthor">${fmt:escapeLooseAmpersands(author)}</h3>
				</c:if>
				<c:set var="resultDetailsThirdLine"><prm:fields fields="${c_value_is_part_of}" result="${result}" fieldDelims=" "/></c:set>
				<span class="EXLResultDetails">${fmt:escapeLooseAmpersands(resultDetailsThirdLine)}</span>
				<c:if test="${not empty result.values[c_value_is_part_of]}">
					<c:set var="displayLds50">${result.values[c_value_lds_50][0]}</c:set>
					<c:if test="${not empty displayLds50 and displayLds50 eq 'peer_reviewed'}" >
						<fmt:message key='default.fulldisplay.constants.peer_reviewed'/>
					</c:if>
				</c:if>				
					<c:if test="${empty result.values['availlibrary'][0] and not empty result.values[c_value_frbrgroupid] and result.values[c_value_frbrtype][0] eq 5 and result.recordSource eq 'Primo Central Search Engine'}">
						<h3 class="EXLResultFourthLine">
							<c:out value="${result.values['source'][0]}" escapeXml="false"/>
						</h3>
					</c:if>
				

				<%-- check to make sure the content exists before rendering the fourth line unnecesarily --%>
				<c:set var="fourthLineContent"><prm:fields fields="${form.resultView[2]}" result="${result}" fieldDelims="${form.displayFieldsDelimiters[2]}"/></c:set>
				<c:if test="${not empty fourthLineContent}">
					<h3 class="EXLResultFourthLine">${fmt:escapeLooseAmpersands(fourthLineContent)}</h3>
				</c:if>
				<c:choose>
					<c:when test="${result.recordSource eq 'Primo Central Search Engine'}">
						<eas:ajaxPlaceHolder styleClass="EXLResultSnippet" id="snippet_${result.values[c_value_recordid][0]}" group="1" message="snippet_${result.values[c_value_recordid][0]}" taskName="snippet"  tagName="p"/>
					</c:when>
					<c:otherwise>
						<eas:ajaxPlaceHolder styleClass="EXLResultSnippet" id="snippet_${result.values[c_value_recordid][0]}" group="2" message="snippet_${result.values[c_value_recordid][0]}" taskName="snippet"  tagName="p"/>
					</c:otherwise>
				</c:choose>

			<c:set var="institution" value="${sessionScope.institutionCode}" />
			<fmt:message key="getit.customized.union_search_code.${institution}" var="unionsearch_tabcode"/>
			<c:set var="urltab" value='<%= request.getParameter("tab") %>'/>
			<c:if test="${urltab!=unionsearch_tabcode}">

				<c:if test="${!form.alma}">
					<prm:available availForm="${form}" dlvIndex="${resultStatus.index}"/>
				</c:if>
			</c:if>

<%-- Start of CODES for customized summary AVA status. By  William NG (OUHK QSYS) Dated: 5 Nov 2015 --%>
 <%@ include file="/csids/tiles/ava_summarystatus_call_ajax.jsp"%>
<%-- End of CODES for customized summary AVA status.--%>

			</div>


			<c:if test="${isFrbr}">
				<cite class="EXLResultFRBR">
					<span class="EXLResultBgFRBR"></span>
						<a class="EXLBriefResultsDisplayMultipleLink" target="_parent" href="${fn:escapeXml(frbrUrl)}">${result.values[c_value_versions][0]}</a>
					<span class="EXLResultBgRtlFRBR"></span>
				</cite>
			</c:if>
			
			<c:if test="${(form.remote)  and (result.values[c_more]==sessionScope[c_more]) and (not empty sessionScope[c_more])}">
				<cite class="EXLResultNew">
					<span class="EXLResultBgNew"></span>
						<a name="newResult${resultStatus.index}"><fmt:message key="brief.New_Result"/></a>
					<span class="EXLResultBgRtlNew"></span>
				</cite>
			</c:if>

			<!-- Facebook Like Button -->
			<c:if test="${searchForm.facebookEnabled and not fn:contains(result.id, 'RS_')}">
				<c:set var="dlRecordURL" value="${sessionScope.serverPwd}dlDisplay.do?vid=${sessionScope.vid}&afterPDS=true&docId=${result.id}" />
				<c:if test="${fn:contains(result.id, 'TN_')}">
					<c:set var="dlRecordURL" value="${dlRecordURL}&loc=adaptor,${result.adaptor}"/>
				</c:if> 
				
				<c:set var="facebookFrameURL" value='<%= URLEncoder.encode((String)pageContext.getAttribute("dlRecordURL"),"UTF-8") %>'/>
				<iframe title="Facebook Like" src="http://www.facebook.com/plugins/like.php?href=${facebookFrameURL}&amp;send=false&amp;layout=button_count&amp;width=46&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font&amp;height=60" scrolling="no" frameborder="0" class="EXLFacebookIframe" allowTransparency="true"></iframe> 
			</c:if>
			<!-- End of Facebook Like Button -->
		</div>
		<div class="EXLTabsRibbon EXLTabsRibbonClosed">
	      <div>
	        <ul id="exlidResult${resultStatus.index}-TabsList" class="EXLResultTabs">

<%-- Start of customized View Online Tab (by William NG (OUHK LIB QSYS). Dated:  26 Nov 2015) --%>
<%@ include file="/csids/tiles/viewonline.jsp"%>
<%-- End of customized View Online Tab --%>


			<c:set var="noFirstTab" value="true"/>
			<c:forEach items="${tabState.tabsOrder}" var="tab" varStatus="tabStatus">
				<!-- index: ${tabStatus.index} length: ${fn:length(tabState.tabsOrder)} -->
			  <c:choose>
				  <c:when test="${noFirstTab==true}">
				  	<c:set var="specialTabClass" value="EXLResultFirstTab "/>
				  </c:when>
				  <c:when test="${tab==tabState.tabsOrder[fn:length(tabState.tabsOrder)-1]}">
				  	<c:set var="specialTabClass" value="EXLResultLastTab "/>
				  </c:when>
				  <c:otherwise>
				  	<c:set var="specialTabClass" value=""/>
				  </c:otherwise>
			  </c:choose>
			  <%-- viewonline,getit_link1,locations,details,reviewsandtags,recommendations,getit_link2 --%>

<%-- Start of modification of the default View Online Tab (by William NG (OUHK LIB QSYS). Dated:  26 Nov 2015) --%>
<%--
        The following codes read in context the institution code which is used to retrive the name of CSIDS Union Search from Pimo Code table.
        Primo Code Table used: "GetIT! Tab1".
        Code used: default.getit.customized.union_search_code.[Institution Code].

        The codes then modify the original condition of showing View Online Tab. The default condition is:
                <c:if test="${tab=='viewonline' && not empty tabState.viewOnlineTab}">
        The modified confition is:
                <c:if test="${tab=='viewonline' && not empty tabState.viewOnlineTab && urltab!=unionsearch_tabcode }">
        Plainly, the default View Online Tab will show if the current Primo Search Tab is not Union Search.
--%>
                        <c:set var="institution" value="${sessionScope.institutionCode}" />
                        <fmt:message key="getit.customized.union_search_code.${institution}" var="unionsearch_tabcode"/>
                        <c:set var="urltab" value='<%= request.getParameter("tab") %>'/>
                        <c:if test="${tab=='viewonline' && not empty tabState.viewOnlineTab && urltab!=unionsearch_tabcode }">
<%-- End of modification of the default  View Online Tab --%>

		          <li id="exlidResult${resultStatus.index}-ViewOnlineTab" class="EXLViewOnlineTab EXLResultTab ${specialTabClass} ${tabState.viewOnlineTab.iconCode}">
					<!-- rum statistics -->
						<prm:boomerang id="getitonline1_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
						opId="getit1" resultDoc="${result}" type="delivery"
						delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
					<!-- end rum statistics -->

					<c:choose>
						<c:when test="${tabState.viewOnlineTab.popOut == 'on'}">
							<c:set var="taburl" value="${tabState.viewOnlineTab.link}"/>
							<c:set var="popoutTarget"> target='_blank' </c:set>
						</c:when>
						<c:otherwise>
							<c:url var="taburl" value="${displayURL}">
								<c:param name="tabs" value="viewOnlineTab"/>
								<c:param name="gathStatTab" value="true"/>
							</c:url>
							<c:set var="popoutTarget"></c:set>
						</c:otherwise>
					</c:choose>
				  	<c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.viewOnlineTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  	</c:set>

<!-- For LIB IS request, value "&nbsp;${linkTitleSuffix}" is removed from that <a> tag title attribute; dated: 27 Apr 2015 -->
					<a href="${fn:escapeXml(taburl)}"  title="${linkTitle}" ${popoutTarget}>
					<fmt:message key="${tabState.viewOnlineTab.label}"/></a>
				  </li>
	  			  <c:set var="noFirstTab" value="false"/>
			  </c:if>
			  <c:if test="${tab=='getit_link1' && not empty tabState.requestTab}">
				<li id="exlidResult${resultStatus.index}-RequestTab" class="EXLRequestTab EXLResultTab ${specialTabClass} ${tabState.requestTab.iconCode}">
					<!-- rum statistics -->
					<prm:boomerang id="getit1request_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
					opId="getit1" resultDoc="${result}" type="delivery"
					delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
					<!-- end rum statistics -->
					<c:choose>
					<c:when test="${tabState.requestTab.popOut == 'on' && fn:contains(tabState.requestTab.link,'requestTab.do')}">
						<c:url var="taburl" value="${displayURL}">
							<c:param name="tabs" value="requestTab"/>
							<c:param name="gathStatTab" value="true"/>
						</c:url>
						<c:set var="popoutTarget"> target='_blank' </c:set>
					</c:when>
					<c:when test="${tabState.requestTab.popOut == 'on'}">
						<c:set var="taburl" value="${tabState.requestTab.link}"/>
						<c:set var="popoutTarget"> target='_blank' </c:set>
					</c:when>
					<c:otherwise>
						<c:url var="taburl" value="${displayURL}">
							<c:param name="tabs" value="requestTab"/>
							<c:param name="gathStatTab" value="true"/>
						</c:url>
						<c:set var="popoutTarget"></c:set>
					</c:otherwise>
					</c:choose>
				  <c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.requestTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  </c:set>
					<a href="${fn:escapeXml(taburl)}"  title="${linkTitle}&nbsp;${linkTitleSuffix}" ${popoutTarget}>
					<fmt:message key="${tabState.requestTab.label}"/></a>
				  </li>
	  			  <c:set var="noFirstTab" value="false"/>
			  </c:if>

			  <c:if test="${tab=='locations' && not empty tabState.locationsTab}">
				 <c:url var="taburl" value="${displayURL}">
						<c:param name="tabs" value="locationsTab"/>
						<c:param name="gathStatTab" value="true"/>
				 </c:url>
				 <c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.locationsTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				 </c:set>

<!-- For LIB IS request, value "&nbsp;${linkTitleSuffix}" is removed from that <a> tag title attribute; dated: 27 Apr 2015 -->
		         <li id="exlidResult${resultStatus.index}-LocationsTab" class="EXLLocationsTab EXLResultTab ${specialTabClass}">
		         	<a href="${fn:escapeXml(taburl)}" title="${linkTitle}"><fmt:message key="${tabState.locationsTab.label}"/></a>

					 <!-- rum statistics -->
					<prm:boomerang id="locations_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
					opId="locationTab" resultDoc="${result}" type="locations"
					delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
					<!-- end rum statistics -->
				 </li>
				 <c:set var="noFirstTab" value="false"/>
			  </c:if>

			  <c:if test="${tab=='details' && not empty tabState.detailsTab}">
				  <c:url var="taburl" value="${displayURL}">
						<c:param name="tabs" value="detailsTab"/>
						<c:param name="gathStatTab" value="true"/>
				  </c:url>
				  <c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.detailsTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  </c:set>

<!-- For LIB IS request, value "&nbsp;${linkTitleSuffix}" is removed from that <a> tag title attribute; dated: 27 Apr 2015 -->
		          <li id="exlidResult${resultStatus.index}-DetailsTab" class="EXLDetailsTab EXLResultTab ${specialTabClass}"><a href="${fn:escapeXml(taburl)}"  title="${linkTitle}"><fmt:message key="${tabState.detailsTab.label}"/></a>
					<!-- rum statistics -->
				 	<prm:boomerang id="details_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
					opId="detailsTab" resultDoc="${result}" type="details"
					delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
				 	<!-- end rum statistics -->
				  </li>
				  <c:set var="noFirstTab" value="false"/>
			  </c:if>
			  <c:if test="${tab=='reviewsandtags' && not empty tabState.tagsReviewsTab}">
				  <c:url var="taburl" value="${displayURL}">
						<c:param name="tabs" value="tagreviewsTab"/>
						<c:param name="gathStatTab" value="true"/>
				  </c:url>
				  <c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.tagreviewsTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  </c:set>

				  <c:set var="tabTitleReviews"><fmt:message key="${tabState.tagsReviewsTab.label}"/></c:set>
		          <li id="exlidResult${resultStatus.index}-ReviewsTab" class="EXLReviewsTab EXLResultTab ${specialTabClass}"><a href="${fn:escapeXml(taburl)}"  title="${linkTitle}&nbsp;${linkTitleSuffix}">${fn:escapeXml(tabTitleReviews)}</a>
				 	 <!-- rum statistics -->
					 <prm:boomerang id="tagsreview_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
						opId="tagReviewTab" resultDoc="${result}" type="tagsreview"
						delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
					 <!-- end rum statistics -->
				 </li>
				  <c:set var="noFirstTab" value="false"/>
			  </c:if>
			  <c:if test="${tab=='recommendations' && not empty tabState.recommendationsTab}">
				  <c:url var="taburl" value="${displayURL}">
						<c:param name="tabs" value="recommendTab"/>
						<c:param name="gathStatTab" value="true"/>
				  </c:url>
				  <%--
				  <c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.recommendTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  </c:set>
				  --%>
				  <c:set var="linkTitle">
					  <fmt:message key="default.recommendationtab.recommendations_loading">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  </c:set>
				  <li id="exlidResult${resultStatus.index}-RecommendTab" class="EXLRecommendTab EXLResultTab ${specialTabClass}"><a href="${fn:escapeXml(taburl)}"  title="${linkTitle}&nbsp;${linkTitleSuffix}"><fmt:message key="${tabState.recommendationsTab.label}"/></a>
					<!-- rum statistics -->
					<prm:boomerang id="recommendation_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
					opId="recommendationTab" resultDoc="${result}" type="recommendation"
					delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
					<!-- end rum statistics -->
				  </li>
				  <c:set var="noFirstTab" value="false"/>

				  <%-- variable showRecommendTab is set to true when at least record
				  has recommendation, prechecked by SearchHelper.isRecommendationEnabled.
				  In another word, showRecommendTab is false when neither bX nor bibtip
				  is enabled to indicate there's no need to call RecommendationsTabAction for further check.
				  --%>
				  <c:set var="showRecommendTab" value="true"/>				  
			  </c:if>
			  <c:if test="${tab=='getit_link2' && not empty tabState.moreTab}">

<!-- CODES for More Tab start here (dated: 6 Jun 2015) -->
                        <!-- The following added statements checks if title held by OUHK, and display the More Tab if so -->
                        <c:set var="selfholdill" value="false" />
                        <c:forEach var="i" begin="0" end="${fn:length(result.values.source)}" step="1">
                                <c:if test="${fn:contains(result.values.source[i], 'csidsou')}">
                                        <c:set var="selfholdill" value="true" />
                                </c:if>
                        </c:forEach>
                        <c:if test="${selfholdill}">
		          <li id="exlidResult${resultStatus.index}-MoreTab" class="EXLMoreTab EXLResultTab ${specialTabClass} ${tabState.moreTab.iconCode}">
					<!-- rum statistics -->
				 	<prm:boomerang id="getit2_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
					opId="getit2" resultDoc="${result}" type="getit2"
					delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
				 	<!-- end rum statistics -->
					<c:choose>
						<c:when test="${tabState.moreTab.popOut == 'on'}">
							<c:set var="taburl" value="${tabState.moreTab.link}"/>
							<c:set var="popoutTarget"> target='_blank' </c:set>
						</c:when>
						<c:otherwise>
							<c:url var="taburl" value="${displayURL}">
								<c:param name="tabs" value="moreTab"/>
								<c:param name="gathStatTab" value="true"/>
							</c:url>
							<c:set var="popoutTarget"></c:set>
						</c:otherwise>
					</c:choose>
				  	<c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.moreTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  	</c:set>

<!-- For LIB IS request, value "&nbsp;${linkTitleSuffix}" is removed from that <a> tag title attribute; dated: 27 Apr 2015 -->
					<a href="${fn:escapeXml(taburl)}"  title="${linkTitle}" ${popoutTarget}>
						<fmt:message key="${tabState.moreTab.label}"/>
					</a>
				  </li>
			</c:if>
<!-- CODES for More Tab end here -->

				  <c:set var="noFirstTab" value="false"/>
			  </c:if>
			  <c:if test="${tab=='citations' && not empty tabState.citationsTab}">
		      	<li id="exlidResult${resultStatus.index}-CitationsTab" class="EXLCitationsTab EXLResultTab ${specialTabClass} EXLServiceConditionalTab" style="display:none;">
		          	<input class="EXLServiceConditionalTabService" type="hidden" value="${tabState.citationsTab.serviceName}"/>
		          	<input class="EXLServiceConditionalTabRecord" type="hidden" value="${result.id}"/>
	 	          	<c:url var="taburl" value="${displayURL}">
						<c:param name="tabs" value="conditionalTab"/>
						<c:param name="gathStatTab" value="true"/>
						<c:param name="tabRealType" value="citations"/>						
				  	</c:url>
				  	<c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.citationsTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  	</c:set> 
 		          	<a href="${fn:escapeXml(taburl)}" title="${linkTitle}&nbsp;${linkTitleSuffix}"><fmt:message key="${tabState.citationsTab.label}"/></a> 				
				 	<!-- rum statistics -->
					<prm:boomerang id="citations_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
						opId="citationsTab" resultDoc="${result}" type="citations"
						delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
					 <!-- end rum statistics -->
				 </li>
				 <c:set var="noFirstTab" value="false"/>
			  </c:if>
			  <c:if test="${tab=='onlinereviews' && not empty tabState.onlinereviewsTab}">
		         <li id="exlidResult${resultStatus.index}-OnlinereviewsTab" class="EXLOnlinereviewsTab EXLResultTab ${specialTabClass} EXLServiceConditionalTab" style="display:none;">
		          	<input class="EXLServiceConditionalTabService" type="hidden" value="${tabState.citationsTab.serviceName}"/>
		          	<input class="EXLServiceConditionalTabRecord" type="hidden" value="${result.id}"/>
	 	          	<c:url var="taburl" value="${displayURL}">
						<c:param name="tabs" value="conditionalTab"/>
						<c:param name="gathStatTab" value="true"/>
						<c:param name="tabRealType" value="onlinereviews"/>						
				  	</c:url>
				  	<c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.onlinereviewsTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  	</c:set> 
 		          	<a href="${fn:escapeXml(taburl)}"  title="${linkTitle}&nbsp;${linkTitleSuffix}"><fmt:message key="${tabState.onlinereviewsTab.label}"/></a> 				
				 	<!-- rum statistics -->
					<prm:boomerang id="onlinereviews_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
						opId="onlinereviewsTab" resultDoc="${result}" type="onlinereviews"
						delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
					 <!-- end rum statistics -->
				 </li>
				 <c:set var="noFirstTab" value="false"/>
			  </c:if>
			  <c:if test="${tab=='browseshelf' && not empty tabState.browseshelfTab}">
		          <li id="exlidResult${resultStatus.index}-BrowseshelfTab" class="EXLBrowseshelfTab EXLResultTab ${specialTabClass}">
	 	          <c:url var="taburl" value="${displayURL}">
						<c:param name="tabs" value="browseshelfTab"/>
						<c:param name="gathStatTab" value="true"/>
						<c:param name="tabRealType" value="browseshelf"/>						
						<c:param name="callNumber" value="${result.callNumber}"/>						
						<c:param name="callNumberBrowseField" value="${result.callNumberBrowseField}"/>						
				  </c:url>
				  <c:set var="linkTitle">
					  <fmt:message key="brief.tabs.links.title.browseshelfTab">
					  	<fmt:param>${strippedTitle}</fmt:param>
					  </fmt:message>
				  </c:set> 
 		          <a href="${fn:escapeXml(taburl)}"  title="${linkTitle}&nbsp;${linkTitleSuffix}"><fmt:message key="${tabState.browseshelfTab.label}"/></a> 				
				 	 <!-- rum statistics -->
					<prm:boomerang id="browseshelf_${resultStatus.index}" boomForm="${searchForm}" pageId="brief"
						opId="browseshelfTab" resultDoc="${result}" type="browseshelf"
						delivery="${searchForm.delivery[resultStatus.index]}" noOther="false" index="${result.resultNumber}"/>
					 <!-- end rum statistics -->
				 </li>
				 <c:set var="noFirstTab" value="false"/>
			  </c:if>
			</c:forEach>

<%-- Start of CODES for ILL Tab (by William NG (OUHK LIB QSYS). Dated: 26 Nov 2015) --%>
<%@ include file="/csids/tiles/ill.jsp"%>
<%-- End of CODES for ILL Tab. --%>

	        </ul>
	      </div>
	    </div>

			<c:set var="resultStatusIndex" value="${resultStatus.index}"/>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-viewOnlineTab" class="EXLResultTabContainer EXLContainer-viewOnlineTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-requestTab" class="EXLResultTabContainer EXLContainer-requestTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-locationsTab" class="EXLResultTabContainer EXLContainer-locationsTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-detailsTab" class="EXLResultTabContainer EXLContainer-detailsTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-tagreviewsTab" class="EXLResultTabContainer EXLContainer-tagreviewsTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-recommendTab" class="EXLResultTabContainer EXLContainer-recommendTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-moreTab" class="EXLResultTabContainer EXLContainer-moreTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-citationsTab" class="EXLResultTabContainer EXLContainer-citationsTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-browseshelfTab" class="EXLResultTabContainer EXLContainer-browseshelfTab EXLResultTabContainerClosed">
		    </div>
		    <div id="exlidResult${resultStatusIndex}-TabContainer-onlinereviewsTab" class="EXLResultTabContainer EXLContainer-onlinereviewsTab EXLResultTabContainerClosed">
		    </div>		    

		</td>
	</c:if><!-- End of ${!isFrbrNewDisplay} condition -->

   </tr>

			<!-- Begin:  Additional Bars Results -->
			<c:forEach items="${form.additionalBarsResults}" var="bar" varStatus="barStatus">
				<c:if test="${resultStatus.index + 1 == (bar.barLocation)}">
					<%@ include file="/tiles/additionalBar.jspf" %>			
				</c:if>
			</c:forEach>

			<!-- End:  Additional Bars Results -->

		</c:forEach>
 </tbody>
</table>


<c:choose>
	<c:when test="${form.alma}">
		<c:set var="op">az</c:set>
		<c:set var="pageId">search</c:set>
	</c:when>
	<c:when test="${searchForm.mode eq 'Basic' and empty searchForm.pag and !param.fromLogin and searchForm.ct ne 'facet' and searchForm.ct ne 'frb'}">
		<c:set var="op">do</c:set>
		<c:set var="pageId">search</c:set>
	</c:when>
	<c:when test="${searchForm.mode eq 'Advanced' and empty searchForm.pag and !param.fromLogin and searchForm.ct ne 'facet' and searchForm.ct ne 'frb'}">
		<c:set var="op">advancedSearch</c:set>
		<c:set var="pageId">search</c:set>
	</c:when>
	<c:when test="${searchForm.pag eq 'nxt' and !param.fromLogin and searchForm.ct ne 'facet' and searchForm.ct ne 'frb'}">
		<c:set var="op">paging${searchForm.plsp.currentPageNumber}</c:set>
		<c:set var="pageId">brief</c:set>
	</c:when>
	<c:when test="${searchForm.pag eq 'prv' and !param.fromLogin and searchForm.ct ne 'facet' and searchForm.ct ne 'frb'}">
		<c:set var="op">previous</c:set>
		<c:set var="pageId">brief</c:set>
	</c:when>
	<c:when test="${searchForm.ct eq 'facet'}">
		<c:set var="op">${param.fctN}</c:set>
		<c:set var="pageId">refine</c:set>
	</c:when>
	<c:when test="${searchForm.ct eq 'frb'}">
		<c:set var="op">frbr</c:set>
		<c:set var="pageId">refine</c:set>
	</c:when>
	<c:otherwise>
		<c:set var="op">novalue</c:set>
		<c:set var="pageId">novalue</c:set>
	</c:otherwise>
</c:choose>


<prm:boomerang id="searchStat" boomForm="${searchForm}" pageId="${pageId}"
				opId="${op}" resultDoc="${searchForm.searchResult.results[0]}" type=""
				delivery="${searchForm.delivery[0]}" noOther="true" index="${param.indx}"/>


<%-- we embed this in the page so the prefetch mechanism knows what its configuration is.--%>
<script type="text/javascript">
//<![CDATA[
var exlPrefetchConfiguration = {
	enabled : '${searchForm.prefetchEnabled}',
	bulkSize :'${searchForm.prefetchBulkSize}',
	repeat : '${searchForm.prefetchRepeat}',
	current : 0,
	timeout: '${sessionScope.ajaxTimeout}'
}

$('.EXLBriefResultsDisplayCoverImage img').error(function(){
	thumbnailHide(this);
}).load(function(){
	var resultNumber = $(this).parents('.EXLResult').children('.EXLResultNumber');
	thumbnailPop(resultNumber.text(),this);
});

<c:if test="${showRecommendTab == 'true'}">
	addLoadEvent(checkRecommendations);
</c:if>
<!-- PRM-17057 Call to PC and get data for the conditional tab  -->
addLoadEvent(checkConditional);


// ]]>
</script>
<noscript>This feature requires javascript</noscript>

<c:if test="${searchForm.ct ne 'AdvancedSearch' and searchForm.ct ne 'BasicSearch' and op ne 'novalue' and pageId ne 'novalue' and not empty searchForm.searchString}">
	<script type="text/javascript">
		boomCallToRum('searchStat',true);
	</script>
	<noscript>This feature requires javascript</noscript>
</c:if>

<c:if test="${!isFrbrNewDisplay && fn:length(form.searchResult.results)>0 && searchForm.showSnipp}">
	<eas:ajaxCaller jsRenderer="jquery" prettyPrint="true"/>
</c:if>
<prm:userText styleId="result" type="endingText"/>

<prm:boomerang id="browseResultStat" boomForm="${searchForm}" pageId="search"
				opId="browseRelated" resultDoc="${searchForm.searchResult.results[0]}" type=""
				delivery="${searchForm.delivery[0]}" noOther="true" index="${param.indx}"/>

<c:if test="${(searchForm.mode != null) &&(searchForm.mode eq 'BrowseSearch')}">
	<script type="text/javascript">
		boomCallToRum('browseResultStat',true);
	</script>
	<noscript>This feature requires javascript</noscript>
</c:if>

<%-- Prepare the customized View Online Tab by calling a Javascript function in csids/javascript/csids.js. (by William NG (OUHK LIB QSYS). Dated: 12 Nov 2015) --%>
<script language="javascript">
        prepareQViewOnlineTab();
	prepareQILLTab();
</script>

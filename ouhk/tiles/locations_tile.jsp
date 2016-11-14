<%@ include file="/views/taglibsIncludeAll.jspf" %>
<!--  include setSearchForm.jspf before -->
<%@ include file="/views/include/setSearchForm.jspf"%>
<!--  include setSearchForm.jspf after   -->
<html:form action="/action/locations">
	<html:hidden property="func(${recordId})" value="submit"/>
	<html:hidden property="fn" value="submit"/>
	<html:hidden property="recIds" value="${recordId}"/>
	<html:hidden property="tabs" value="locationsTab"/>
	<html:hidden property="recIdxs" value="${recordResultIndex}"/>
	<html:hidden property="elementId" value="${recordElementId}"/>
	<html:hidden property="renderMode" value="prefetchXml"/>
	<html:hidden property="displayMode" value="${locationsTabForm.displayMode}"/>
	<html:hidden property="startPosition" value="1"/>

	<input type="hidden" id="clickedId"/>

	<c:set var="noValidUserMessage"><fmt:message key='requesttab.user.not.valid'/></c:set>
	<c:choose>
		<c:when test="${locationsTabForm.brief}">
			<c:set var="methodDisplay">brief</c:set>
		</c:when>
		<c:otherwise>
			<c:set var="methodDisplay">full</c:set>
		</c:otherwise>
	</c:choose>

	<c:set var='instSortOtherFlag' value='0'/>

    <div id="exlidResult${recordResultIndex}-TabHeader" class="EXLTabHeader">
      <div class="EXLTabHeaderContent"> </div>
      <div id="exlidTabHeaderButtons${recordResultIndex}" class="EXLTabHeaderButtons">
        <!--begin sendTo Ribbon-->
	          	<prm:sendTo recordId="${recordId}"  pushToTypeList="${form.pushToTypeList}" fromEshelf="${form.fromEshelf}" fn="${form.fn}"  inBasket="${form.inBasket[0]}" tabForm="${locationsTabForm}" />
        <!--end sendTo Ribbon-->
      </div>

    </div>

	<c:set var="displayURLRemoved" value="${requestScope.resultTileDisplayURL_reqDecQryUTF8}" />
	<c:set var="tabState" value="${searchForm.recordTabs[result.id]}"/>
	<!-- defect 7768 -->
	<c:if test="${not empty result.values[c_value_frbrgroupid] and  result.values[c_value_frbrtype][0] eq 7}">
		<c:set var="frbrHits" value="${sessionScope[result.id]}"/>
	</c:if>

	<c:url var="displayURL" value="display.do?${displayURLRemoved}" >
		<c:param name="tabs" value="locationsTab"/>
		<c:param name="ct" value="display"/>
		<c:param name="fn" value="search"/>
		<c:param name="doc" value="${recordId}"/>
		<c:param name="indx" value="${recordResultIndex}-1"/>
		 <c:param name="recIds" value="${recordId}"/>
         <c:param name="recIdxs" value="${recordResultIndex}"/> 
         <c:param name="tabsProcess" value="RTARefreshTab"/>
		<c:param name="elementId" value="${resultStatus.index}"/>
		<c:param name="renderMode" value="poppedOut"/>
		<c:param name="displayMode" value="full"/>
		<c:param name="frbrVersion" value="${frbrHits}"/>
	</c:url>
	 

	<c:set var="feedbackMessage">
		<fmt:message key="default.loc.update_loc"/>
		<a href="${fn:escapeXml(displayURL)}" id="RefreshUrl${recordResultIndex}">
		<fmt:message key="default.loc.update_loc_link">
			<fmt:param>${prefilterVar}</fmt:param>
		</fmt:message>
		</a>
	</c:set>
	
	 

<div id="exlidResult${recordResultIndex}-TabContent" class="EXLTabContent EXLLocationsTabContent">
		<div style="display:none" id="refresh${recordResultIndex}" class="EXLTabMessage EXLTabLocationsRtaRefresh">		
			<strong>${feedbackMessage} </strong>
		</div> 
		<c:if test="${locationsTabForm.displayDropDown and (fn:length(locationsTabForm.locationsResultsMap[recordId])> 0)}">
<%@ page import="com.exlibris.primo.tabs.LocationsTabForm" %>
<c:set var = 'locationsFilter'><%=LocationsTabForm.LOCATIONS_FILTER%></c:set>

<br/>
<c:set var="filterDisplayed" value="false"/>
<div id="holdings" class="EXLLocationsDataFrame">
	<fieldset id="holdingsForm" class="exlidLocationsHoldingsFilter">
			 		<strong><fmt:message key="fulldisplay.locations.select"/></strong>
	<c:forEach items="${locationsTabForm.filtersDropDown[recordId]}" var="ddElement" varStatus="ddstatus">
		<c:if test="${fn:length(ddElement.fieldValues) >1}">
			<label for="exlidLocationstTabFormSelect${ddElement.fieldName}" id="exlidLocationstTabFormSelect${ddElement.fieldName}${recordId}">
								<fmt:message key="fulldisplay.locations.${ddElement.fieldName}"/><em class="EXLHide"> (ok)</em>:
			</label>
			<c:set var="filterDisplayed" value="true"/>
			<html:select name="locationsTabForm" property="selectedValue[${ddstatus.index}] " styleClass="dropDownElementField EXLDropDownElementField">
								<html:option value=""><fmt:message key="fulldisplay.locations.all"/></html:option>
								<c:forEach items="${ddElement.field2Values}" var="fieldValue">								
					<c:if test="${not empty fieldValue}">
						<c:choose>
							<c:when test="${ddElement.fieldName eq locationsFilter}">
												<html:option value="${fieldValue.value}"><fmt:message key="${fieldValue.key}"/></html:option>
							</c:when>
							<c:otherwise>
												<html:option value="${fieldValue.value}">${fieldValue.value}</html:option>
							</c:otherwise>
						</c:choose>
					</c:if>
				</c:forEach>
			</html:select>
		</c:if>
	</c:forEach>

	</fieldset>

			   	<input type="submit" value=<fmt:message key="fulldisplay.locations.go"/> name="submit"/>
</div>
<br/>
</c:if>


<c:if test="${fn:length(locationsTabForm.locationsResultsMap[recordId])<1}">
	<c:if test="${locationsTabForm.prefetch}">
		<script type="text/javascript">
			$('#${recordElementId}-locationsTab').get(0).tabUtils.disableTab();
		</script>
	</c:if>
	<c:choose>
	<c:when test="${!locationsTabForm.ilsgStatus}">
			<div class="EXLSystemFeedback">
				<span>
				<fmt:message key='loc.ilsg_connection_error'/>
				</span>
			</div>
	</c:when>
	<c:otherwise>
			<div class="EXLSystemFeedback">
				<span>
				<fmt:message key='loc.no_locations'/>
				</span>
			</div>
	</c:otherwise>
	</c:choose>
</c:if>
<c:set var="heightWithFilter" value="EXLLocationListContainer17"/>
<c:if test="${filterDisplayed}">
	<c:set var="heightWithFilter" value="EXLLocationListContainer13"/>
</c:if>
<div class="EXLLocationListContainer ${heightWithFilter}">

	  <!--location1-->
	  <c:forEach var="result" items="${locationsTabForm.locationsResultsMap[recordId]}" varStatus="status">
       	  <c:if test="${locationsTabForm.instSort}">
      		<c:if test="${result.myInst && status.index eq 0}">
						<h4>
							<fmt:message key="facets.facet.availability.locations.facet_library_myinstitution">
						<fmt:param>
							${sessionScope.institutionFromCT}
						</fmt:param>
					</fmt:message>
				</h4>
			</c:if>
			<c:if test="${!result.myInst && instSortOtherFlag eq '0'}">
				<c:set var="instSortOtherFlag" value="1"/>
				<h4><fmt:message key="facets.facet.availability.locations.facet_library_otherinstitution"/></h4>
			</c:if>
		  </c:if>
		<c:choose>

		<c:when test="${!result.ovp}">
						<c:set var="libraryNameLink">
							<span class="EXLLocationsTitle EXLLocationsTitlePopout">
								<span class="EXLLocationsTitleContainer">
									<a href="${result.linkUrl}" target="_blank" title='' class="EXLLocationsTitleIconPopout">
										<fmt:message key="${result.library}"/>
									</a>
								</span>
							</span>
						</c:set>
		</c:when>

					<c:when test="${result.ovp and ((fn:length(locationsTabForm.locationsResultsMap[recordId]) eq 1) or (((!locationsTabForm.emptySelection) and (empty result.locationsItemList) and (empty result.locationsHolding or empty result.locationsHolding.locationFieldsList or result.locationsHolding.locationFieldsList.size()==0))))}">
						<c:set var="libraryNameLink">
							<span class="EXLLocationsTitle">
								<%-- span class="<!--create new class-->">
									<img src="<fmt:message key='ui.images.locationstitle.iconlocationsminus'/>" alt="No locations" title="No locations"/>
								</span --%>
								<span class="EXLLocationsTitleContainer">
									<fmt:message key="${result.library}"/>
								</span>
							</span>
						</c:set> 
		</c:when>

		<c:otherwise>
			<c:choose>
				<c:when test="${locationsTabForm.displaySorting}">
					<c:url var="expendLocation" value="expand.do" >
										<c:param name="fn" value="expend"/>
										<c:param name="id" value="${result.ilsApiId}${fmt:getLongHashCode(result.mainLocations)}${fmt:getLongHashCode(result.callNumber)}${fmt:getLongHashCode(result.secondaryLocations)}${fmt:getLongHashCode(result.fullHoldingsRecordId)}"/>
										<c:param name="ilsApiId" value="${result.ilsApiId}"/>
										<c:param name="mainLocation" value="${result.mainLocations}"/>
										<c:param name="callNumber" value="${result.callNumber}"/>
										<c:param name="secondaryLocation" value="${result.secondaryLocations}"/>
										<c:param name="holdingRecordID" value="${result.fullHoldingsRecordId}"/>
										<c:param name="linkIndex" value="${status.index}"/>
										<c:param name="recIds" value="${recordId}"/>
										<c:param name="recIdxs" value="${recordResultIndex}"/>
										<c:param name="elementId" value="${recordElementId}"/>
										<c:param name="renderMode" value="prefetchXml"/>
										<c:param name="displayMode" value="${methodDisplay}"/>
										<c:param name="tabs" value="locationsTab"/>
									<c:param name="startPosition" value="1"/>
									</c:url>

								<c:set var="altTextForImg">
									<fmt:message key='loc.expand_locations'><fmt:param><fmt:message key='${result.library}'/></fmt:param></fmt:message>
								</c:set>
								<c:set var="titleForImg">
									<fmt:message key='loc.expand_locations'><fmt:param><fmt:message key='${result.library}'/></fmt:param></fmt:message>
								</c:set>

								<c:set var="additionalParams" value="${fn:replace(form.reqDecQry, '&tabs=locationsTab', '')}"></c:set>
								<c:set var="libraryNameLink">
									<span class="EXLLocationsTitle">
										<a href="${expendLocation}&${additionalParams}" class="EXLLocationsIcon">
											<img src="<fmt:message key='ui.images.locationstitle.iconlocationsminus'/>" alt="${altTextForImg}" title="${titleForImg}"/>
										</a>
										<span class="EXLLocationsTitleContainer">
											<fmt:message key="${result.library}"/>
										</span>
									</span>
								</c:set>
		 		</c:when>
		 		<c:otherwise>
								<c:set var="libraryNameLink">
									<span class="EXLLocationsTitle">
										<a class="EXLLocationsIcon">
											<img src="<fmt:message key='ui.images.locationstitle.iconlocationsminus'/>" alt="${altTextForImg}" title="${titleForImg}"/>
										</a>
										<span class="EXLLocationsTitleContainer">
											<fmt:message key="${result.library}"/>
										</span>
									</span>
								</c:set>
				</c:otherwise>
			</c:choose>
		</c:otherwise>
		</c:choose>

<!-- IMPORTANT 	If you change this logic be sure to fix rtaAvailability.js START-->

		<c:choose>
			<c:when test="${result.availStatus eq 'available'}">
				<c:set var="avialClass">EXLResultStatusAvailable</c:set>
			</c:when>
			<c:when test="${result.availStatus eq 'unavailable'}">
				<c:set var="avialClass">EXLResultStatusNotAvailable</c:set>
			</c:when>
					<c:when test="${(result.availStatus eq 'due_date')}">
						<c:set var="avialClass">EXLResultStatusNotAvailable</c:set>
					</c:when>					
			<c:otherwise>
				<c:set var="avialClass">EXLResultStatusMaybeAvailable</c:set>
			</c:otherwise>
		</c:choose>
<!-- IMPORTANT 	If you change this logic be sure to fix rtaAvailability.js END-->



		<div class="EXLLocationList">${libraryNameLink}
			<span class="EXLLocationInfo">
				<strong><fmt:message key="${fmt:ncrEscape(result.collection)}" prefix="dummy"></fmt:message></strong>
				<cite>${fmt:safeHTMLEntitiesEncode(result.callNumber)}</cite>

<%-- Start of customized location tab AVA status (William NG (OUHK) dated: 4 Feb 2016)--%>
<%@ include file="/csids/tiles/avastatus_call_ajax.jsp"%>
<%-- End of customized location tab AVA status --%>

<%-- The Following codes are default Primo Codes and are commented out for no use. (William NG (OUHK) Dated: 2 Mar 2016. --%>
<%--
						<c:set var="msg"><fmt:message key='fulldisplay.availabilty.${result.availStatus}'/></c:set>
						<c:if test="${(result.availStatus eq 'due_date') && (empty result.dueDate)}">
							<c:set var="msg"><fmt:message key='fulldisplay.availabilty.unavailable'/></c:set>
						</c:if>
						<!-- IMPORTANT	If you change this logic be sure to fix rtaAction.java START-->
						<c:if test="${(result.availStatus eq 'due_date') && (!empty result.dueDate)}" >
							<c:set var="msg">
								<fmt:message key='fulldisplay.availabilty.${result.availStatus}'>
									<fmt:param>${result.dueDate}</fmt:param>
								</fmt:message>
							</c:set>
						</c:if>
						<!-- IMPORTANT	If you change this logic be sure to fix rtaAction.java END-->
--%>
						<c:set var ="rtaAvailId" value="rtaReturnedStatus${(result.ilsApiId)}${fmt:getLongHashCode(result.mainLocations)}${fmt:getLongHashCode(result.callNumber)}${fmt:getLongHashCode(result.secondaryLocations)}${fmt:getLongHashCode(result.fullHoldingsRecordId)}"/>
						
<%-- The Following codes are default Primo Codes and are commented out for no use. (William NG (OUHK) Dated: 2 Mar 2016. --%>
<%--
						<em id="${rtaAvailId}" class="${avialClass}">${msg}</em>
--%>
<%-- The Following codes are added for escaping the msg "Locations may have changed. Update locations". (William NG (OUHK) Dated: 2 Mar 2016. --%>
						<em id="${rtaAvailId}" class="${avialClass}" style="display:none"></em>
			</span>
	 		<br/>
			<div class="EXLSublocation" id="${(result.ilsApiId)}${fmt:getLongHashCode(result.mainLocations)}${fmt:getLongHashCode(result.callNumber)}${fmt:getLongHashCode(result.secondaryLocations)}${fmt:getLongHashCode(result.fullHoldingsRecordId)}" >
				<prm:locationTable form="${locationsTabForm}" result="${result}" statusIndex="${status.index}" expended="false"/>
			</div>
       </div> <!--end locationsList-->

     	  <!--end EXLLocationListContainer-->

	</c:forEach>


</div>
</div>



<c:if test="${fn:length(locationsTabForm.locationsResultsMap[recordId]) gt 0}">
	<script type="text/javascript">
		<c:if test="${(fn:length(locationsTabForm.locationsResultsMap[recordId]) gt 1) and (locationsTabForm.emptySelection eq 'true' or locationsTabForm.filtersDropDown[recordId] == null)}">
		$('#exlidResult${recordResultIndex}-TabContent .EXLLocationsMoreInfo').hide();
		$('#exlidResult${recordResultIndex}-TabContent .EXLLocationTable').hide(); //hide all the info by default.
		</c:if>
		//switch all the images to a 'plus' and then add an onclick handler.
 		$('#exlidResult${recordResultIndex}-TabContent .EXLLocationList').find('.EXLLocationsIcon img').each(function(){
			var tbl = $(this).parents('.EXLLocationList').find('.EXLLocationTable');
			var tblm = $(this).parents('.EXLLocationList').find('.EXLLocationsMoreInfo');
 			<c:if test="${(fn:length(locationsTabForm.locationsResultsMap[recordId]) gt 1) and (locationsTabForm.emptySelection eq 'true' or locationsTabForm.filtersDropDown[recordId] == null)}">
 					$(this).attr('src',$(this).attr('src').replace('_minus','_plus'));
 			</c:if>
 			if(tbl.html() == null && tblm.html() == null) {
					$(this).attr('src',$(this).attr('src').replace('_minus','_plus'));
 			}

 		}).parents('a').click(function(e){
			e.preventDefault();
 			var img = $(this).children('.EXLLocationsIcon img');
			var tbl = $(this).parents('.EXLLocationList').find('.EXLLocationTable');
			var tblm = $(this).parents('.EXLLocationList').find('.EXLLocationsMoreInfo');
			var a = $(this);
 	 		if(tbl.html() == null && tblm.html() == null) {
 	 			//$(this).parents('.EXLLocationsTitle').siblings('.EXLLocationList').find('.EXLSublocation').html("<div class='EXLTabLoading'></div>");
 	 			$(this).get(0).loadedLocationsAlready = true;
 	 	 		var url = $(this).get(0).href;

 	 	 		prefetch(url,{'zzz':'zzz'},/*error handler*/function (){
                    <c:set var="msg"><fmt:message key="item.noitems"/></c:set>
                    		var jsMsg = '${fn:replace(msg,"'","\\'")}';
                            $(a).parents('.EXLLocationList').find('.EXLSublocation').append('<span class="EXLSublocationError">' + jsMsg + '</span>');
                            //console.log('failed..');
                            //alert($(tblm).html());
					        //if we fail, make sure that we know we still didn't get the location info.
                    });

 	 		}

		    if ($(img).attr('src').indexOf('_plus.')>0 ){  //if the location is currently closed
		    	$(tblm).show();
		        $(tbl).show();
	   		    $(img).attr('src',$(img).attr('src').replace('_plus','_minus'));
	    	}else{
	    		$(tblm).hide();
		        $(tbl).hide();
	   		    $(img).attr('src',$(img).attr('src').replace('_minus','_plus'));
	    	}
		});
 		<c:if test="${not empty param.selectedLocation and fn:length(locationsTabForm.locationsResultsMap[recordId]) gt 1 and locationsTabForm.emptySelection eq 'true'}">
	 		var selectedLocation = '${param.selectedLocation}';
	 		var plusimg = $('#exlidResult${recordResultIndex}-TabContent .EXLLocationList').eq(selectedLocation).find('.EXLLocationsIcon img');
	 		if(plusimg != null){
	 			var hrefVal = $(plusimg).parents('a')[0].href;
	 			$(plusimg).parents('a')[0].href = "#";//this prevents the click() function to proceed to the href		 			
	 			plusimg.click();
	 			$(plusimg).parents('a')[0].href = hrefVal;//this prevents the click() function to proceed to the href
	 		}
 		</c:if>

	/*
 		$('.EXLAdditionalFieldsLink').removeClass('EXLHideInfo').addClass('EXLShowInfo').click(
 			function (e){
 				e.preventDefault();
				if($(this).hasClass('EXLShowInfo')){
					$(this).children('a').attr('title','<fmt:message key="item.hide_details"/>');
	 				$(this).removeClass('EXLShowInfo').addClass('EXLHideInfo').parents('tr').next('.EXLAdditionalFieldsRow').show();
	 			}else{
	 				$(this).children('a').attr('title','<fmt:message key="item.show_details"/>');
	 				$(this).removeClass('EXLHideInfo').addClass('EXLShowInfo').parents('tr').next('.EXLAdditionalFieldsRow').hide();
	 			}
 			});
 		$('.EXLAdditionalFieldsRow').hide();
	*/

			function concatLocations (cdata) {
				var id = $('#clickedId').val();

				//remove old button
				$('#locationPagingButton' + id).remove();

				//find the orig table
			    var existTable = $("#locationsTable" + id);

			    var tableDiv = document.createElement("div");
				tableDiv.innerHTML = cdata;
				// remove summary holdings information
				$(tableDiv).find('.EXLLocationsTabSummaryHoldingsContainer').remove();
				
				var t = tableDiv.getElementsByTagName("table")[0];

			    var trs = t.rows;
				$(trs).remove('.EXLLocationTitlesRow');	//looks for the class!
			    $(trs).each(function(){
			        var tr = $(this);
			       	existTable.append(tr);

			       	if (tr.attr('class') && tr.attr('class').indexOf('EXLAdditionalFieldsRow') > -1) {
			        	tr.hide();
			        }
			    });

			    //located in locationTable.tag
			    addJSToButton('#moreInfoButton' + id, id);
				addJSToRow('.EXLLocationLink${recordResultIndex}_' + id);
			}

			function fetchData(url, data){
				$.ajax({
					global: false,
					success: function(data, textStatus){
						parseXmlAndHandleModificationsOnly(data, true);
					},
					timeout:suggestTimeout(),
					data: escapeAjaxCall(data),
					url: escapeAjaxCall(url)
				});
			}
			
			<c:if test='${locationsTabForm.callRtaForAllInstitutions && param.tabsProcess != "RTARefreshTab"}'>						
					updateRTA(false,true,${recordResultIndex});				
			</c:if>

	</script>
</c:if>

	<script>
	
	$('#RefreshUrl${recordResultIndex}').click(function(e){
		forceTabRefresh(e,$('#RefreshUrl${recordResultIndex}'),'locationsTab');return false;
	});
	</script>

<input type="submit" class="EXLHide"/>
</html:form>





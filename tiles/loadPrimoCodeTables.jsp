<%--
  Dated 3 Oct 2016
  by William NG
  This JSP reads Primo Code Tables into variables; this is to minimize hardcode programming and allow configuration via Primo Code Tables.
--%>

<%-- If this JPS is run before, don't load again. --%>
<c:if test="${not loadbefore}">
<%-- All Primo Code Tables values are read into the following JSTL tags. --%>
<%-- Start of inititialization JSTL variables for later loading --%>
	<%-- Records' source ID. I.e. source system ID --%>
	<c:set var="recordsource" value=""/>
	<%-- Institution current users are in. --%>
	<c:set var="institution" value=""/>
	<%-- User groupd IDs (defined in members' ILS) which have ILL privileges. --%>
	<c:set var="ill_user_group_ids" value=""/>
	<%-- Publisher / publishing place (e.g. S.l, s.i....)  Keywords to be removed for ILL HTML Form. --%>
	<c:set var="pubCopRemovalWords" value=""/>
	<%-- List of consortial membersm. --%>
	<c:set var="consortialMembers" value=""/>
	<%-- Member institutes Primo source system id wording. i.e. PNX <control> <sourceid>. --%>
	<c:set var="sysSourceID" value=""/>
	<%-- Member institutes ILS Library ID. (e.g. OUHK: OUL01) --%>
	<c:set var="ilsLibraryID" value=""/>
	<%-- Member institutes SFX link (View Online tab link)wording. --%>
	<c:set var="sfxWording" value=""/>
	<%-- Mappings from member institutes item record status to CSIDS records status for summary availbility calculation. --%>
	<c:set var="avaStatuses" value=""/>
	<%-- Wordings defined by member institutes ILSs  and Primo NRs (PNX <display><lds47>) for identifying if a resource item is an e-resource. --%>
	<c:set var="eResourceWordings" value=""/>
	<%-- Wordings defined by member institutes ILSs  and Primo NRs (PNX <display><lds47>) for identifying if a resource item is an physical resource. --%>
	<c:set var="physicalWordings" value=""/>
	<%-- Wordings defined by member institutes ILSs  and Primo NRs (PNX <display><lds47>) for identifying if a resource item is an in-process resource. --%>
	<c:set var="inprocessWordings" value=""/>
	<%-- The current search tab users are in.--%>
	<c:set var="current_search_tab" value=""/>
	<%-- Member institute's Union Search Primo Tab code (defined in Primo BO View Widzard). --%>
	<c:set var="urltab" value=""/>
	<%-- Resources type mapping where mapped Primo types have cover icons. --%>
	<c:set var="ilsToPrimoTypeMappings" value=""/>
	<%-- ILS API URLs for item records retrival for Summary Status Tab. --%>
	<c:set var="rtaBaseURL" value=""/>
	<%-- ILS API URLs for item records retrival for Location Tab. --%>
	<c:set var="locRTABaseURL" value=""/>
	<%-- ILS API URLs for item records retrival for ILL.. --%>
	<c:set var="rtaItemURL" value=""/>
	<%-- Book cover providers' URLs. --%>
	<c:set var="bookcoverBaseURL" value=""/>
	<%-- Relais form filling info. --%>
	<c:set var="relaisFormFillInfo" value=""/>
	<%-- Book covers no-cover-image graphic checksums of book cover image providers. --%>
	<c:set var="noImgChecksums" value=""/>
<%-- End of inititialization JSTL variables for later loading --%>

<%-- Start to load Primo Code Table. --%>
	<%-- Read record source id for decide if users are in Union Search. --%>
	<c:set var="recordsource" value='${result.values.source[0]}'/>

	<%-- Read institution code in context from Primo system variable. --%>
	<c:set var="institution" value="${sessionScope.institutionCode}" />

	<%-- Read the current Primo search tab code users are in. --%>
	<c:set var="urltab" value='<%= request.getParameter("tab") %>'/>

	<%-- Read Primo Union Search Tab code by institution in context; defined on Primo Code Table "GetIT! Tab1"  --%>
	<fmt:message key="getit.customized.union_search_code.${institution}" var="unionsearch_tabcode"/>

	<%-- Read the current Primo Search Tab in use in context from Primo system variable. --%>
	<c:set var="current_search_tab" value='<%= request.getParameter("tab") %>'/>

	<%-- Read ILL previlege group IDs string in context, defined in Primo Code Table "ILL Request;
        	the group IDs are IDs on source ILSs and regarded as eligible to make ILL requests.
	        and split the group ids string into an array. --%>
	<fmt:message key="illrequest.customized.illform.privilege.${institution}" var="ill_user_group_id_str"/>
	<c:set var="ill_user_group_ids" value="${fn:split(ill_user_group_id_str,',')}"/>

	<%-- Read the base URL by institution in context, defined in Primo Code Table "ILL Request. --%>
	<fmt:message key="illrequest.customized.illform.baseurl.${institution}" var="illform_baseurl"/>

	<%-- Read the ILS system name by institution in context; defined in Primo Code Table "ILL Request. --%>
	<fmt:message key="illrequest.customized.illform.ils.${institution}" var="ils"/>

	<%-- Read words to be removed from ILL Request Form fields Publisher and Place of Publication; defined in Primo Code Table "ILL Request. --%>
	<fmt:message key="illrequest.customized.illform.pub_cop_removal_keywords" var="pubCopRemovalWordsStr"/>
	<c:set var="pubCopRemovalWords" value="${fn:split(pubCopRemovalWordsStr, ',')}"/>

	<%-- Read member institute codes: i.e. OUHK,TWC,CIHE,CHCHE,HKSYU. (would be added further from Primo BO) --%>
	<fmt:message key="delivery.customized.consortial_members" var="consortialMembersStr"/>
	<c:set var="consortialMembers" value="${fn:split(consortialMembersStr, ',')}"/>

	<%-- Read all book cover image providers name. --%>
	<fmt:message key="getit.customized.bookcover_providers" var="bookcover_providers"/>

	<%-- Read groupped availbility status full list. --%>
	<fmt:message key="delivery.customized.ava.status.fulllist" var="avaStatusFullList"/>

	<%-- Read Primo material types which have image icons full list. --%>
	<fmt:message key="facets.facet.customized.ils_primo_type_mapping_for_image_icon.fulllist" var="ilsToPrimoTypeMappingsFullList"/>

	<%-- Read wordings for checking online resources. --%>
	<fmt:message key="getit.customized.eresource_wording" var="eResourceWordingStr"/>
	<c:set var="eResourceWordings" value="${fn:split(eResourceWordingStr, ',')}"/>

	<%-- Read wordings for checking inprocess resources. --%>
	<fmt:message key="getit.customized.inprocess_wording" var="inprocessWordingStr"/>
	<c:set var="inprocessWordings" value="${fn:split(inprocessWordingStr, ',')}"/>

	<%-- Read wordings for checking inprocess resources. --%>
	<fmt:message key="getit.customized.physical_wording" var="physicalWordingStr"/>
	<c:set var="physicalWordings" value="${fn:split(physicalWordingStr, ',')}"/>


	<%
		String instsStr = pageContext.getAttribute("consortialMembersStr").toString(); 
		String bookcoverProvidersStr = pageContext.getAttribute("bookcover_providers").toString(); 
		String avaStatusFullListStr = pageContext.getAttribute("avaStatusFullList").toString(); 
		String ilsToPrimoTypeMappingsFullListStr = pageContext.getAttribute("ilsToPrimoTypeMappingsFullList").toString(); 
		String[] ilsToPrimoTypeMappingsFullList = ilsToPrimoTypeMappingsFullListStr.split(",");
		String[] insts = instsStr.split(",");
		String[] bookcoverProviders = bookcoverProvidersStr.split(",");
		String[] avaStatusFullList = avaStatusFullListStr.split(",");

		//Read all the CSIDS members Real Time Availability info supply base URL; defined in Primo Code Table "Calculated Availability Text".
		HashMap<String, String> rtaBaseURL = new HashMap<String, String>();
		String keyBase = "delivery.customized.ava.baseurl.";
		for(int i=0; i<insts.length; i++){
			rtaBaseURL.put(insts[i], keyBase + insts[i]);
		} //end for
		pageContext.setAttribute("rtaBaseURL", rtaBaseURL);
	
		HashMap<String, String> locRTABaseURL = new HashMap<String, String>();
		keyBase = "delivery.customized.location_ava.baseurl.";
		for(int i=0; i<insts.length; i++){
			locRTABaseURL.put(insts[i], keyBase + insts[i]);
		} //end for
		pageContext.setAttribute("locRTABaseURL", locRTABaseURL);

	        HashMap<String, String>  rtaItemURL = new HashMap<String, String>();
	        keyBase = "delivery.customized.ava.itemurl."; 
	        for(int i=0; i<insts.length; i++){
        	         rtaItemURL.put(insts[i], keyBase + insts[i]);
	        } //end for
	        pageContext.setAttribute("rtaItemURL",  rtaItemURL);

	        HashMap<String, String>  sysSourceID = new HashMap<String, String>();
	        keyBase = "delivery.customized.system_source_id."; 
	        for(int i=0; i<insts.length; i++){
        	         sysSourceID.put(insts[i], keyBase + insts[i]);
	        } //end for
	        pageContext.setAttribute("sysSourceID",  sysSourceID);

	        HashMap<String, String>  sfxWording = new HashMap<String, String>();
	        keyBase = "getit.customized.sfx_wording."; 
	        for(int i=0; i<insts.length; i++){
			sfxWording.put(insts[i], keyBase + insts[i]);
	        } //end for
	        pageContext.setAttribute("sfxWording",  sfxWording);

	        HashMap<String, String>  ilsLibraryID = new HashMap<String, String>();
	        keyBase = "delivery.customized.ils_library_id."; 
	        for(int i=0; i<insts.length; i++){
			ilsLibraryID.put(insts[i], keyBase + insts[i]);
	        } //end for
	        pageContext.setAttribute("ilsLibraryID",  ilsLibraryID);

	        HashMap<String, String> bookcoverBaseURL = new HashMap<String, String>();
	        keyBase = "getit.customized.bookcover.baseurl."; 
        	for(int i=0; i<bookcoverProviders.length; i++){
			bookcoverBaseURL.put(bookcoverProviders[i], keyBase + bookcoverProviders[i]);
	        } //end for
	        pageContext.setAttribute("bookcoverBaseURL",  bookcoverBaseURL);

	        keyBase = "delivery.customized.ava.status."; 
	        HashMap<String, String[]> avaStatuses = new HashMap<String, String[]>();
		for(int i=0; i<avaStatusFullList.length; i++){
			String[] arry = new String[1];
			arry[0] = keyBase + avaStatusFullList[i];
			avaStatuses.put(avaStatusFullList[i], arry);
		} //end for
	        pageContext.setAttribute("avaStatuses",  avaStatuses);

	        keyBase = "illrequest.customized.illform.relais."; 
	        HashMap<String, HashMap<String,String>> relaisFormFillInfo = new HashMap<String, HashMap<String,String>>();
		for(int i=0; i<insts.length; i++){
			keyBase = keyBase + insts[i];
			HashMap <String,String> hm = new HashMap<String,String>();
			hm.put("keyBase", keyBase);
			relaisFormFillInfo.put(insts[i], hm);
	        	keyBase = "illrequest.customized.illform.relais."; 
		} //end for
	        pageContext.setAttribute("relaisFormFillInfo",  relaisFormFillInfo);

	        keyBase = "facets.facet.customized.ils_primo_type_mapping_for_image_icon."; 
	        HashMap<String, String[]> ilsToPrimoTypeMappings = new HashMap<String, String[]>();
		for(int i=0; i<ilsToPrimoTypeMappingsFullList.length; i++){
			String[] arry = new String[1];
			arry[0] = keyBase + ilsToPrimoTypeMappingsFullList[i];
			ilsToPrimoTypeMappings.put(ilsToPrimoTypeMappingsFullList[i], arry);
		} //end for
	        pageContext.setAttribute("ilsToPrimoTypeMappings",  ilsToPrimoTypeMappings);

	        keyBase = "getit.customized.bookcover.noimg_checksums."; 
	        HashMap<String, String[]> noImgChecksums = new HashMap<String, String[]>();
		for(int i=0; i<bookcoverProviders.length; i++){
			String[] arry = new String[1];
			arry[0] = keyBase + bookcoverProviders[i];
			noImgChecksums.put(bookcoverProviders[i], arry);
		} //end for
	        pageContext.setAttribute("noImgChecksums",  noImgChecksums);
	%>

	<%-- Read all the CSIDS members Real Time Availability info supply base URL; defined in Primo Code Table "Calculated Availability Text". --%>
	<c:forEach var="rtaBaseURLItem" items="${rtaBaseURL}">
		<fmt:message key="${rtaBaseURLItem.value}" var="value"/>
		<c:set target="${rtaBaseURL}" property="${rtaBaseURLItem.key}" value="${value}"/>
	</c:forEach>

	<%-- Read all the CSIDS members Real Time Availability info under Location Tab supply base URL; defined in Primo Code Table "Calculated Availability Text". --%>
	<c:forEach var="locRTABaseURLItem" items="${locRTABaseURL}">
		<fmt:message key="${locRTABaseURLItem.value}" var="value"/>
		<c:set target="${locRTABaseURL}" property="${locRTABaseURLItem.key}" value="${value}"/>
	</c:forEach>

	<%-- Read all the CSIDS members Real Time Availability at item level, for ILL from multi-volume item level request. --%>
	<c:forEach var="rtaItemURLItem" items="${rtaItemURL}">
		<fmt:message key="${rtaItemURLItem.value}" var="value"/>
		<c:set target="${rtaItemURL}" property="${rtaItemURLItem.key}" value="${value}"/>
	</c:forEach>

	<%-- Read all the CSIDS members Source ID (in form "csids[institute]"). --%>
	<c:forEach var="sysSourceIDItem" items="${sysSourceID}">
		<fmt:message key="${sysSourceIDItem.value}" var="value"/>
		<c:set target="${sysSourceID}" property="${sysSourceIDItem.key}" value="${value}"/>
	</c:forEach>

	<%-- Read all the CSIDS members SFX Wording in view of end users. --%>
	<c:forEach var="sfxWordingItem" items="${sfxWording}">
		<fmt:message key="${sfxWordingItem.value}" var="value"/>
		<c:set target="${sfxWording}" property="${sfxWordingItem.key}" value="${value}"/>
	</c:forEach>

	<%-- Read all the CSIDS members SFX Wording in view of end users. --%>
	<c:forEach var="ilsLibraryIDItem" items="${ilsLibraryID}">
		<fmt:message key="${ilsLibraryIDItem.value}" var="value"/>
		<c:set target="${ilsLibraryID}" property="${ilsLibraryIDItem.key}" value="${value}"/>
	</c:forEach>

	<%-- Read all the book cover images providers' URLs. --%>
	<c:forEach var="bookcoverBaseURLItem" items="${bookcoverBaseURL}">
		<fmt:message key="${bookcoverBaseURLItem.value}" var="value"/>
		<c:set target="${bookcoverBaseURL}" property="${bookcoverBaseURLItem.key}" value="${value}"/>
	</c:forEach>

	<%-- Read all the ava statuses into groups. --%>
	<c:forEach var="avaStatusesItem" items="${avaStatuses}">
		<fmt:message key="${avaStatusesItem.value[0]}" var="value"/>
		<c:set var="statuses" value="${fn:split(value, ',')}"/>
		<c:set target="${avaStatuses}" property="${avaStatusesItem.key}" value="${statuses}"/>
	</c:forEach>

	<%-- Read all the ava statuses into groups. --%>
	<c:forEach var="ilsToPrimoTypeMappingsItem" items="${ilsToPrimoTypeMappings}">
		<fmt:message key="${ilsToPrimoTypeMappingsItem.value[0]}" var="value"/>
		<c:set var="materialtypes" value="${fn:split(value, ',')}"/>
		<c:set target="${ilsToPrimoTypeMappings}" property="${ilsToPrimoTypeMappingsItem.key}" value="${materialtypes}"/>
	</c:forEach>

	<%-- Read all the ava statuses into groups. --%>
	<c:forEach var="noImgChecksumsItem" items="${noImgChecksums}">
		<fmt:message key="${noImgChecksumsItem.value[0]}" var="value"/>
		<c:set var="checksums" value="${fn:split(value, ',')}"/>
		<c:set target="${noImgChecksums}" property="${noImgChecksumsItem.key}" value="${checksums}"/>
	</c:forEach>

	<%-- Read all the Relais setup for each relevent institute. --%>
	<c:forEach var="relaisFormFillInfoItem" items="${relaisFormFillInfo}">
		<c:set var="memberRelais" value="${relaisFormFillInfoItem.value}"/>
		<c:set var="keybase" value="${memberRelais.keyBase}"/>
		<fmt:message key="${keybase}.authen_url" var="authenUrl"/>
		<fmt:message key="${keybase}.apikey" var="apiKey"/>
		<fmt:message key="${keybase}.user_group" var="userGroup"/>
		<fmt:message key="${keybase}.library_symbol" var="librarySymbol"/>
		<c:set target="${memberRelais}" property="authenUrl" value="${authenUrl}"/>
		<c:set target="${memberRelais}" property="apiKey" value="${apiKey}"/>
		<c:set target="${memberRelais}" property="userGroup" value="${userGroup}"/>
		<c:set target="${memberRelais}" property="librarySymbol" value="${librarySymbol}"/>
		<c:set target="${relaisFormFillInfoItem.value}" property="${relaisFormFillInfoItem.key}" value="${memberRelais}"/>
	</c:forEach>
</c:if>
<c:set var="loadbefore" value="true"/>
<%-- End of loading Primo Code Table. --%>

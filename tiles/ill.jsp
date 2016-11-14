<%--
 README:
 Version 2.3 (19 Oct 2016)
 By William NG (OUHK LIB QSYS) and Paul CHIU (HKSYU LIB QSYS).
 This JSP file (ill.jsp) is written for QESS CSIDS Porject which involves multi-institutes using ExLibris Primo.
 This JSP decides if conditions of showing ILL Tab meet; if so, detects if the current title is multi- or single- volume then invoke ther respective JSPs.

Conditions of Showing up ILL Tab/Link:
        1. The codes check if an item is an ILL-able item;
        2. if the item is not held by home library;
        3. if the logon person is admin/academic staff;
        4. if the item is available for check out (not in special status "In Process", "On Order"...)
        5. and, if the current Primo Search Tab is Union Search.

If all yes above, this script further decides if the current title is multi-volume or single-volume. Then:
 For multi-volume title, the JSP "ill_form_multi.jsp" will be used to show up the ILL Tab.
 For single-volume title, "ill_form_single.jsp" will be used to show up the ILL Tab.

--%>

<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%-- Retrive CSIDS Primo Customized Code Table codes and environment varialbes. (see the JSP's source codes for descriptions.) --%>
<%@ include file="/csids/tiles/loadPrimoCodeTables.jsp"%>

<%-- Initialize testing concdition variables --%>
<c:set var="self_own" value="false" />
<c:set var="have_privilege" value="false" />
<c:set var="ill_lendable" value="false" />
<c:set var="in_union_search" value="false" />

<%-- Walk through the user group IDs ILL privilege list to see if the current user's group is in the list. --%>
<c:forEach var="i" begin="0" end="${fn:length(ill_user_group_ids)}" step="1">
        <c:if test="${sessionScope.PdsUserGroup.equals(ill_user_group_ids[i])}">
                <c:set var="have_privilege" value="true" />
        </c:if>
</c:forEach>

<%-- 
        Test if the current Primo Search Tab in use is the institution's Union Search Code.
        The cutomized View Online Tab will show only if this is the case
        - i.e. if currently the user is using individual catalog, the cutomized View Online Tab WON'T show.
                  The idea of testing current Primo Search Tab is from Paul CHIU (HKSYU LIB SYS); a credit must go to him.

        In Union Search setting, there is no current Primo Tab (request.getParameter("tab") will return null) be got when  viewing Primo full record on "e-Shelf".
        For entertaining the cases, record source ID is checked if it contains 'csids' which means this is a Union Search record.
        All the context variables are loaded from loadPrimoCodeTables.jsp.
 --%>
<c:if test="${urltab.equals(unionsearch_tabcode)  or fn:contains(recordsource, 'csids')}">
        <c:set var="in_union_search" value="true" />
</c:if>

<c:set var="ill_source" value="" />

<%-- Walk through PNX <display><lds48>s and determine if the current title is ILL-lendable.--%>
<%-- PNX <display><lds48>s are prepared by Primo Pipe NRs of each institute in advance..--%>
<c:forEach var="i" begin="0" end="${fn:length(result.values.lds48)}" step="1">

<%-- Remember the source(s) (the institute(s) holds) of the title and store in "ill_source"; --%>
<%-- "ill_source" will then be passed to a ILL HTML Form at last --%>
        <c:set var="ill_source" value="${ill_source}${result.values.lds48[i]} " />

        <c:if test="${fn:contains(result.values.lds48[i], 'ILL-')}">
                <c:set var="ill_lendable" value="true" />
        </c:if>
</c:forEach>

<%-- Walk through PNX <display><lds47>s and determine if the current title is owned by home institute.--%>
<%-- PNX <display><lds47>s are prepared by Primo Pipe NRs of each institute in advance. It contains institute, record id, and material type info.--%>
<c:forEach var="i" begin="0" end="${fn:length(result.values.lds47)}" step="1">
        <c:if test="${fn:contains(result.values.lds47[i], institution)}">
                <c:set var="self_own" value="true" />
        </c:if>
</c:forEach>

<%-- Show ILL an ILL tab only if the conditions are met.--%>
<c:if test="${not self_own && ill_lendable && in_union_search  && have_privilege}"> 

	<c:set var="MULTIVOL" value="false" />
	<%-- Check if PNX tags <display><lds46> have the value "VOLUME", and treat the record is multi-volume record if that is the case. --%> 
	<%-- The PNX tags <display><lds46> are prepared by Primo Pipe NRs of each institute in advance. --%> 
        <c:forEach var="i" begin="0" end="${fn:length(result.values.lds46)}" step="1">
                <c:set var="TMP" value="${fn:split(result.values.lds46[i], '=')}" />
                <c:choose>
                        <c:when  test="${TMP[0]=='VOLUME'}">
                                <c:set var="MULTIVOL" value="true" />
                        </c:when>
		</c:choose>
	</c:forEach>

	<%-- Start. Added by Paul CHIU (HKSYU LIB) --%>
	<%-- For obtaining authen token to come with the ILL HTML form. --%>
        <c:set var="userId" value="${sessionScope.userId}"/>
        <c:set var="AuthorizationId" value="-PROMETHEUS-PROMETHEUS-PROMETHEUS-PROMETHEUS-PROMETHEUS"/>

	<%
		String barcode="";
		if (pageContext.getAttribute("userId").toString()!=null) {
			barcode = pageContext.getAttribute("userId").toString();
		} //end if
		if(pageContext.getAttribute("ils").toString() != null){
			String ils = pageContext.getAttribute("ils").toString();
			if(ils.equals("RELAIS")){
				HashMap<String,HashMap <String,String>> relaisFormFillInfo = (HashMap<String, HashMap<String,String>>) pageContext.getAttribute("relaisFormFillInfo");
				String institution = (String) pageContext.getAttribute("institution");
				String authorizationId = prepareRelaisILLFormSubmission(barcode,institution,relaisFormFillInfo);
				pageContext.setAttribute("AuthorizationId", authorizationId);
			} //end if
		} //end if
	%>
	<%-- End. Added by Paul CHIU (HKSYU LIB) --%>

	<%-- Prepare ILL HTML form. The default display style is "none"; the ILL tab will only displays if there is available item decided by calling "ava_illsummarystatus_call_ajax.jsp" --%>
	<%-- Prepare multi-volume HTML form. "ill_form_multi.jsp" will be called after a click on the ILL tab. The link is prepared by csids.js fucntion "prepareQILLTab()".--%>
	<c:if test="${MULTIVOL}">
		<li id="QResult${resultStatus.index}-ILLTab" style="display:none"
			class="QILLTab EXLResultTab ${specialTabClass}">
			<a href="javascript:void();">
				<fmt:message key="ILL"/>
			</a> 
		</li>
	</c:if>
	<%-- Prepare single-volume HTML form.--%>
	<c:if test="${not MULTIVOL}">
		<%@ include file="/csids/tiles/ill_form_single.jsp"%>
		&nbsp;
	        <li id="QResult${resultStatus.index}-ILLTab" style="display:none">
        		<a href="javascript:illform2${resultStatus.index}.submit()">
	                <fmt:message key="ILL"/>
        	</a>
	        </li>
	</c:if>

        <%-- Check the avaibility status and show the ILL Tab only if the item is avaiable. --%>
        <%@ include file="/csids/tiles/ava_illsummarystatus_call_ajax.jsp"%>

</c:if>

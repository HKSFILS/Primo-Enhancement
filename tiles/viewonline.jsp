<%--

README:
	By William NG (OUHK LIB QSYS).
	Version 1.4 (Dated 13 Oct 2016)
	This JSP script viewonline.jsp is called by resultTile.jsp and fullRecord.jsp to show up the customized View Online Tab.
	This script further tests if the title assocated has an E-copy then show up the View Online Tab if that is the case.
	The test relies on Primo PNX <display> <lds47> which contains record type info for determining if a title has an E-copy.
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

	<c:set var="webaccessible" value="false"/>

	<%-- Walk throught <display> <lds47> and <display><format> in the PNX and decide if the title has an E-version. --%>
	<c:if test="${fn:length(result.values.lds47) != 0}">
		<c:forEach var="i" begin="0" end="${fn:length(result.values.lds47) - 1}" step="1">
			<c:set var="recid" value="${result.values.lds47[i]}"/>
			<c:forEach var="j" begin="0" end="${fn:length(eResourceWordings) - 1}" step="1">
				<c:if test="${fn:contains(fn:toUpperCase(recid), fn:toUpperCase(eResourceWordings[j]) )}">
					<c:set var="webaccessible" value="true"/>
				</c:if>
			</c:forEach>
			<c:forEach var="j" begin="0" end="${fn:length(inprocessWordings) - 1}" step="1">
				<c:if test="${fn:contains( fn:toUpperCase(recid), fn:toUpperCase(inprocessWordings[j]) )}">
					<c:set var="webaccessible" value="false"/>
				</c:if>
			</c:forEach>
		</c:forEach>
	</c:if>

	<%-- Only show the customized View Online Tab if the title has an E-version available. --%>
	<c:if test="${webaccessible}">
		<li id="exlidResult${resultStatus.index}-QViewOnlineTab"
			class="QViewOnlineTab EXLResultTab ${specialTabClass} EXLResultFirstTab">
			<a href="/primo_library/libweb/csids/tiles/viewonline_tab.jsp?recordId=${result.id}"><fmt:message key="getit.tab1_full"/></a> 
		</li>
	</c:if>
</c:if>

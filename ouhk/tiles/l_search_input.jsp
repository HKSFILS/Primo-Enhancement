<!-- l_search_input.jsp begin -->
<%@ include file="/views/taglibsIncludeAll.jspf" %>
<%@ page import="com.exlibris.primo.utils.SessionUtils" %>

<%
	String key = "l_search_input.jsp";
	String prefix = "";
	String jsp_default = "/tiles/searchTile.jsp";
%>

<%@ include file="../../general/jsp_mapping_retriver.jsp" %>

<c:set var="jsp_page"><%=jspPage%></c:set>
<!-- resolved jsp page for search tile: ${jsp_page} -->
<tiles:insert page="${jsp_page}" />

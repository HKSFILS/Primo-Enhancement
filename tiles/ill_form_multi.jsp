<%-- 
 README:
	Version 1.4
	Dated: 19 Oct 2016
	By William NG (OUHK LIB QSYS) and Paul CHIU (HKSYU LIB SYS) 
	This JSP (ill_form_multi.jsp) is invoked by ill.jsp for volume level ILL HTML form feeding.
--%>

<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>

<%-- Load core Primo JSTL. --%>
<%@ include file="/views/taglibsIncludeAll.jspf" %>

<%-- Retrive CSIDS Primo Customized Code Table codes and environment varialbes. (see the JSP's source codes for descriptions.) --%>
<%@ include file="/csids/tiles/loadPrimoCodeTables.jsp"%>

<%-- Load core CSIDS functions. --%>
<%@ include file="/csids/tiles/csids.jsp"%>

<link rel="stylesheet" type="text/css" href="/primo_library/libweb/csids/css/csids.css">
<%
	//JSTL RTAItemURL is loaded by loadPrimoCodeTables.jsp from Primo Code Table
	HashMap<String,String> rtaItemURL = (HashMap<String,String>) pageContext.getAttribute("rtaItemURL");

	request.setCharacterEncoding("UTF-8");
	String recordId = request.getParameter("recordId");
	recordId = recordId.replace("</div", "");

	//Default HTTP get method use ISO-8859 to encode, this converts to UTF-8 instead, for Chinese handling.
	// PNX tags <display> <lds46> are passed by the calling HTTP get. <lds46> stores the requested title information (e.g. title, author...).
	String lds46Str = new String(request.getParameter("lds46").getBytes("ISO-8859-1"), "utf-8"); 

	// PNX Tags <display> <lds47> stores institutes' ILS IDs and other info (e.g. format, status...).	
	String lds47Str = request.getParameter("lds47");

	// PNX Tags <display> <lds46> info of which institute holds an ILL-able item (e.g. ILL-HKSYU).	
	String lds48Str = request.getParameter("lds48");

	//Decode the beforehand encoded characters; the characters are encoded in "csids/javascript/EXLTabAPI.03b_modified.js".
	lds46Str = lds46Str.replace("^^", " ");
	lds46Str = lds46Str.replace("^", "=");

	String[] lds46 = lds46Str.split(",");
	String[] lds48 = lds48Str.split(",");
	String[] lds47 = lds47Str.split(",");
	String urlStr = "";
	String homeInst = pageContext.getAttribute("institution").toString();
	String illInsts[] = lds48; 
	String ids[] = lds47; 
	String inst = "";
	String ilsrecordid;
	ArrayList<String> items = new ArrayList<String>();
	String query = "";
	for(int i=0; i<ids.length; i++){
		try{
		ilsrecordid = ids[i].split("-")[1];
		inst = ids[i].split("-")[0];
		urlStr = rtaItemURL.get(inst);
		//Get item records from the institute's ILS API in real time. getBibItems() is defined in csids.jsp.
		String avas[] = getBibItems(inst, ilsrecordid, urlStr);
		if(avas!=null){
			for(int j=0; j<avas.length; j++){
				if(avas[j].contains("UNAVA"))
					continue;
				items.add(avas[j]);
			} //end for
                       if(items.size() == 0){
				String str = inst + " record problem., , ,ERROR:,AVA";
				items.add(str);
                        } //end if
		} //end if
		} //end try
		catch(Exception e){}
	} //end for

	//Sort item record results.
	Collections.sort(items, new Comparator<String>() {
        @Override
	public int compare(String s1, String s2) {
		return s1.compareToIgnoreCase(s2);
	}
	});

        pageContext.setAttribute("items", items.toArray());
        pageContext.setAttribute("lds46", lds46);

%>
<html>
<head>
<script type="text/javascript" src="/primo_library/libweb/csids/javascript/csids.js"></script>
<script type="text/javascript" src="/primo_library/libweb/csids/javascript/EXLTabAPI.03b_modified.js"></script>
<script type="text/javascript" src="/primo_library/libweb/csids/javascript/jquery-1.11.3.js"></script>
<style>
.EXLTocContent {overflow:n;overflow-x:hidden;}
</style>
<br>
<fmt:message key="illrequest.customzied.select_volume"/>
<hr>
<c:forEach var="j" begin="0" end="${fn:length(items) - 1}" step="1">
	<c:set var="item" value="${fn:split(items[j], ',')}" />
        <c:set var="INST" value="${item[0]}" />
	<c:if test="${INST != institution and items[j] != ''}">
        <c:set var="AUTHOR" value="" />
        <c:set var="AUFIRST" value="" />
        <c:set var="AULAST" value="" />
        <c:set var="AUCORP" value="" />
        <c:set var="ADDAU" value="" />
        <c:set var="TITLE" value="" />
        <c:set var="SERIESTITLE" value="" />
        <c:set var="PUB" value="" />
        <c:set var="COP" value="" />
        <c:set var="DATE" value="" />
        <c:set var="ISBN" value="" />
        <c:set var="MULTIVOL" value="false" />
        <c:set var="VOLNO" value="0" />
        <c:set var="VOLUMETOTAL" value="" />
        <c:set var="ISBN_obtained" value="false" />
        <c:set var="EDITION" value="" />
        <c:set var="FORMAT" value="" />
        <c:set var="LOCATION" value="${item[1]}" />
        <c:set var="CALLNO" value="${item[3]}" />
	<c:if test="${item[3] != 'NOVOL'}">
	        <c:set var="VOL" value="${item[2]}" />
	</c:if>
	<c:if test="${fn:contains(VOL, 'NOVOL') or fn:contains(VOL, 'c.') }">
	        <c:set var="VOL" value="" />
	</c:if>
        <c:set var="STATUS" value="${item[4]}" />

	<%-- Preparing the ILL request title info. (Obtained from <lds46> --%>
        <c:forEach var="i" begin="0" end="${fn:length(lds46)}" step="1">
                <c:set var="TMP" value="${fn:split(lds46[i], '=')}" />
                <c:choose>
                        <c:when test="${TMP[0]=='COP' && COP ==''}">
                                <c:set var="COP" value="${TMP[1]}" />
                        </c:when>
                        <c:when test="${TMP[0]=='EDITION'}">
                                <c:set var="EDITION" value="${TMP[1]}" />
                        </c:when>
                        <c:when test="${TMP[0]=='PUB' && PUB == ''}">
                                <c:set var="PUB" value="${TMP[1]}" />
                        </c:when>
                        <c:when test="${TMP[0]=='DATE'}">
                                <c:set var="DATE" value="${TMP[1]}" />
                        </c:when>
                      <c:when test="${TMP[0]=='ISBN' && not MULTIVOL}">
                                <c:if test="${not ISBN_obtained}">
                                        <c:set var="ISBN" value="${TMP[1]}" />
                                        <c:set var="ISBN_obtained" value="true" />
                                </c:if>

                                <c:set var="ISBN" value="${fn:replace(ISBN, '-', '')}" />
                                <c:set var="ISBN" value="<%=processISBN(pageContext.getAttribute(\"ISBN\").toString())%>" />
                        </c:when>
                        <c:when test="${TMP[0]=='BTITLE'}">
                                <c:set var="TITLE" value="${TMP[1]}" />
                                <c:if test="${TMP[2] != null}">
                                        <c:set var="TITLE" value="${TITLE} = ${TMP[2]}" />
                                </c:if>
                                <c:set var="TITLE" value="${fn:replace(TITLE, '\\\"', '\\\'')}" />
                        </c:when>       
                        <c:when  test="${TMP[0]=='SERIESTITLE'}">
                                <c:set var="SERIESTITLE" value="${TMP[1]}" />
                        </c:when>
                        <c:when  test="${TMP[0]=='AU'}">
                                <c:set var="AUTHOR" value="${TMP[1]}" />
                        </c:when>
                        <c:when  test="${TMP[0]=='AUFIRST'}">
                                <c:set var="AUFIRST" value="${TMP[1]}" />
                        </c:when>
                        <c:when  test="${TMP[0]=='AULAST'}">
                                <c:set var="AULAST" value="${TMP[1]}" />
                        </c:when>
                        <c:when  test="${TMP[0]=='AUCORP'}">
                                <c:set var="AUCORP" value="${TMP[1]}" />
                        </c:when>
                        <c:when  test="${TMP[0]=='ADDAU'}">
                                <c:set var="ADDAU" value="${TMP[1]}" />
                        </c:when>

                        <c:when  test="${TMP[0]=='VOLUME'}">
                                <c:set var="MULTIVOL" value="true" />
                                <c:set var="VOLNO" value="${TMP[1]}" />
                                <c:set var="VOLUMETOTAL" value="${TMP[1]}" />
                        </c:when>
                </c:choose>
        </c:forEach>

        <c:if test="${AUTHOR == '' && AULAST != ''}">
                <c:set var="AUTHOR" value="${AULAST}" />
        </c:if>
        <c:if test="${AUTHOR == '' && AUFIRST != ''}">
                <c:set var="AUTHOR" value="${AUFIRST}" />
        </c:if>

        <c:if test="${AUTHOR == '' && AULAST != ''}">
                <c:set var="AUTHOR" value="${AULAST}" />
        </c:if>

        <c:if test="${AUTHOR ==''}">
                <c:set var="AUTHOR" value="${AUCORP}" />
        </c:if>
        <c:if test="${AUTHOR ==''}">
                <c:set var="AUTHOR" value="${ADDAU}" />
        </c:if>
        <c:if test="${AUTHOR ==''}">
                <c:set var="AUTHOR" value="N/A" />
        </c:if>
	
	<%-- Remove Library CAT internal marking for publishing info. --%>
        <c:set var="PUB" value="${fn:replace(PUB, 's.n', '')}" />
        <c:set var="PUB" value="${fn:replace(PUB, 'S.l', '')}" />
        <c:set var="PUB" value="${fn:replace(PUB, 's.l', '')}" />
        <c:set var="PUB" value="${fn:replace(PUB, 's.l.', '')}" />
        <c:set var="COP" value="${fn:replace(COP, 'S.l', '')}" />
        <c:set var="COP" value="${fn:replace(COP, 's.n', '')}" />
        <c:set var="COP" value="${fn:replace(COP, 's.l.', '')}" />
        <c:set var="COP" value="${fn:replace(COP, 's.l', '')}" />

       <%-- Prepare a HTML form, hidden in property, for submiting to Aleph or Relais ILL Form, depends on context --%>
        <c:choose>
		<%-- For Aleph OPAC ILL form--%>
                <c:when test="${ils == 'ALEPH'}">
                        <c:set var="TITLE" value="${TITLE}" />
                        <c:if test="${MULTIVOL and  item[2]!='NOVOL'}">
                                <c:set var="ISBN" value="" />
                        </c:if>

                        <form style="display:none" action="${illform_baseurl}" method="post" name="illform${j}"
                                accept-charset="UTF-8" id="illform${j}" target="illForm" >
                        <input name="func" type="hidden" value="new-ill-request-l" />
                        <input name="request_type" type="hidden" value="BOOK" />
                        <input name="BIB___FMT___" type="hidden" value="BK" />
                        <input name="BIB___LDR___" type="hidden" value="^^^^^nam^a22^^^^^^a^4500" />
                        <input name="BIB___008___" type="hidden" value="------b----------------r-----000-0-und-d" />
                        <input name="ILLUNIT" type="hidden" value="" />
                        <input name="Z40___MEDIA" type="hidden" value="L-PRINTED" />
                        <input name="Z40_M_DATE_TO" type="hidden" value="+365" /><input name="Z40___MEDIA" type="hidden" value="C-COPY" />
                        <input name="Z40___MEDIA_SEND_METHOD" type="hidden" value="S" />
                        <input type="hidden"  name="Z40___COPYRIGHT_LETTER" type="checkbox" value="Y" />
                        <input name="COPYRIGHT_MANDATORY" type="hidden" value="Y" />
                        <input name="UPDATE_COPYRIGHT_LETTER" type="hidden" value="Y" />
                        <input name="author" type="hidden" value="${AUTHOR}" />
                        <input name="title" type="hidden" value="${TITLE}" />
                        <input name="sub_title" type="hidden" value="SUBTITLE" />
                        <input name="series" type="hidden" value="${SERIESTITLE}" />
                        <input name="year" type="hidden" value="${DATE}" />
                        <input name="publisher" type="hidden" value="${PUB}" />
                        <input name="publication_place" type="hidden" value="${COP}" />
                        <input name="isbn" type="hidden" value="${ISBN}" />
                        <input name="volume" type="hidden" value="${VOL}" />
                       <c:set var="today" value="<%=getToday()%>" />
                        <c:set var="ill_available" value=""/>
                        <c:set var="ill_source" value="${fn:replace(ill_source, 'ILL-', '')}"/>
                        <c:set var="lds48str" value="${fn:join(result.values.lds48, '^')}"/>
                        <input id="ill_source${j}" name="source" type="hidden" value="CSIDS:~~EDITION=${EDITION}~~${STATUS}(Chked:${today})" />
                        </form>
                </c:when>

		<%-- For Relais ILL form--%>
                <c:when test="${ils == 'RELAIS'}">

		<%-- Start. Added by Paul CHIU (HKSYU LIB) --%>
                  <c:set var="TITLE" value="${fn:escapeXml(TITLE)}" />
                  <c:set var="AUTHOR" value="${fn:escapeXml(AUTHOR)}" />
                  <c:set var="PUB" value="${fn:escapeXml(PUB)}" />
		<%-- End. Added by Paul CHIU (HKSYU LIB) --%>

                        <form style="display:none" action="${illform_baseurl}" method="get" name="illform${j}"
                                accept-charset="UTF-8" id="illform${j}" target="illForm" >

			<%-- Start. Added by Paul CHIU (HKSYU LIB) --%>
			<%-- Add AuthorizationId for Relais--%>
                        <input type='hidden' name='authzid' value='${AuthorizationId}'/>
                        <input type='hidden' name='genre' value='Book'/>
                        <input type='hidden' name='PT' value='P'/>
                        <input type='hidden' name='UT' value='P'/>
                        <input type='hidden' name='LS' value='HKSYU'/>
                        <input type='hidden' name='group' value='patron'/>
                        <input type='hidden' name='PI' value='${sessionScope.userId}'/>
                        <input type='hidden' name='UL' value='${sessionScope.userId}'/>
			<%-- End. Added by Paul CHIU (HKSYU LIB) --%>

                        <input type='hidden' name='rft.user' value='${sessionScope.userId}'/>
                        <input type='hidden' name='username' value='${sessionScope.userName}'/>
                        <input type='hidden' name='rft.au' value='${AUTHOR}'/>
                        <input type='hidden' name='rft.btitle' value='${TITLE}'/>
                        <input type='hidden' name='publisher' value='${PUB}'/>
                        <input type='hidden' name='pubplace' value='${COP}'/>
                        <input type='hidden' name='pubdate' value='${DATE}'/>
                        <input type='hidden' name='edition' value='${EDITION}'/>
                        <input type='hidden' name='rft.isbn' value='${ISBN}'/>
                        <input type='hidden' name='req_id' value='${sessionScope.userId}'/>

			<%-- Start. Added by Paul CHIU (HKSYU LIB) --%>
			<input name="volume" type="hidden" value="${VOL}"/>
			<input type='hidden' name='possup' value='${ill_source}'/>
			<%-- End. Added by Paul CHIU (HKSYU LIB) --%>

                        <c:set var="today" value="<%=getToday()%>" />
                        <c:set var="ill_available" value=""/>
                        <c:set var="ill_source" value="${fn:replace(ill_source, 'ILL-', '')}"/>
                        <c:set var="lds48str" value="${fn:join(result.values.lds48, '^')}"/>
                        <input id="ill_source${j}" name="source" type="hidden" value="CSIDS:${STATUS}(Chked:${today})" />
                        </form>
                </c:when>
        </c:choose>

        <c:if test="${fn:contains(CALLNO,'ERROR')}">
                ${VOL} &nbsp;
                ${INST} &nbsp;
        </c:if>
        <c:if test="${not fn:contains(CALLNO,'ERROR')}">
	        <a href="javascript:illform${j}.submit()">	
		<%-- List out each volume. --%>
	        ${VOL} &nbsp;
		${INST} &nbsp; 
	        ${LOCATION} ( 
	        ${CALLNO} )
	        </a>
	</c:if>
	<hr>
</c:if>
</c:forEach>
<title>Cogito, Ergo Sum.</title>
</head>
<body>
</body>
</html> 

<%--
 README:
 Version 2.3.1 (27 Sep 2016)
 By William NG (OUHK LIB QSYS) and Paul CHIU (HKSYU LIB SYS)
 This JSP file (ill_form_sinble.jsp) is written for QESS CSIDS Porject which involves multi-institutes using ExLibris Primo.
 This JSP reads PNX records and pack a title information into a HTML form and at last feeds the information into ILS's ILL Form.

The Way to Pack Title Info to Aleph/Relias's ILL Form:
 Title info is obtained from PNX records <display> <lds46> which is prepared ealier.
 The form of title info is of each value [key]=[value] (e.g. TITLE="Being and Time") in <lds46> of PNX; this program decodes the info and pack them into a HTML <form>.
 The HTML <form> contains <input> with an ID "ill_source#" which records which member library holds the title.
 The <input> "ill_source#" also records if the item is available for ILL when the title is held by certain library (default value: LOADING(Chked:${today});
 But to use it, it must be updated by Javascript, which contains RTA checking function, after this form loaded. The RTA checking script is outside of this JSP file.
 The <input> "ill_source#" also serves as an intermediate storage of "Edition" information which will be decoded on Aleph ILL HTML form.
 
 The HTML <form> will eventually submits itself to an ILS's ILL form.

Version 2.3 update:
	Lines added by Paul CHIU (HKSYU LIB) for codes which work with Relias ILL form.
--%>

<%-- Initialize title information for HTML form feeding.--%>
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
	<c:set var="ISBN_obtained" value="false" />
	<c:set var="EDITION" value="" />
	<c:set var="FORMAT" value="" />

<%-- Reading title information from PNX Tags <display> <lds46> into variables.--%>
<%-- PNX Tags <display> <lds46> are prepared by Primo Pipe NRs of each institute in advance. They store bib info for ILL request.--%>
	<c:forEach var="i" begin="0" end="${fn:length(result.values.lds46)}" step="1">
		<c:set var="TMP" value="${fn:split(result.values.lds46[i], '=')}" />
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
				<%-- processISBN is a fucntion in csids.jsp.--%>
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

	<c:set var="TITLE" value="${TITLE}" />
	<%-- Remove library CAT internally markings for publishing info. --%>
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
		<%-- Checking home ILS. For Aleph ILL Form. --%>
		<%-- Variable "ils" is defined in loadPrimoCodeTables.jsp. --%>
		<c:when test="${ils == 'ALEPH'}">
			<form style="display:none" action="${illform_baseurl}" method="post" name="illform2${resultStatus.index}"
				accept-charset="UTF-8" id="illform2${resultStatus.index}" target="illForm2" >
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
			<c:set var="today" value="<%=getToday()%>" />
			<c:set var="ill_available" value=""/>
			<c:set var="ill_source" value="${fn:replace(ill_source, 'ILL-', '')}"/>
			<c:set var="lds48str" value="${fn:join(result.values.lds48, '^')}"/>
			<input id="ill_source${resultStatus.index}" name="source" type="hidden" value="CSIDS:~~EDITION=${EDITION}~~LOADING(Chked:${today})" />
			</form>
		</c:when>

		<%-- Checking home ILS.  For Relias ILL Form. --%>
		<%-- Variable "ils" is defined in loadPrimoCodeTables.jsp. --%>
		<c:when test="${ils == 'RELAIS'}">

		<%-- Start. Added by Paul CHIU (HKSYU LIB) --%>
                <c:set var="TITLE" value="${fn:escapeXml(TITLE)}" />
                <c:set var="AUTHOR" value="${fn:escapeXml(AUTHOR)}" />
                <c:set var="PUB" value="${fn:escapeXml(PUB)}" />

		<form style="display:none" action="${illform_baseurl}" method="get" name="illform2${resultStatus.index}"
				accept-charset="UTF-8" id="illform2${resultStatus.index}" target="illForm2" >
		<%--End. Added by Paul CHIU (HKSYU LIB) --%>

		<%-- Start. Added by Paul CHIU (HKSYU LIB). AuthorizationId for Relais--%>
			<input type='hidden' name='authzid' value='${AuthorizationId}'/>
                        <input type='hidden' name='genre' value='Book'/>
                        <input type='hidden' name='PT' value='P'/>
                        <input type='hidden' name='UT' value='P'/>
                        <input type='hidden' name='LS' value='HKSYU'/>
                        <input type='hidden' name='group' value='patron'/>
                        <input type='hidden' name='PI' value='${sessionScope.userId}'/>
                        <input type='hidden' name='UL' value='${sessionScope.userId}'/>
		<%-- End. Added by Paul CHIU (HKSYU LIB). AuthorizationId for Relais--%>

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
			<c:set var="today" value="<%=getToday()%>" />
			<c:set var="ill_available" value=""/>

			<%--Start. Added by Paul CHIU (HKSYU LIB) --%>
			<input type='hidden' name='possup' value='${ill_source}'/>
			<%--End. Added by Paul CHIU (HKSYU LIB) --%>

			<c:set var="ill_source" value="${fn:replace(ill_source, 'ILL-', '')}"/>
			<c:set var="lds48str" value="${fn:join(result.values.lds48, '^')}"/>
			<input id="ill_source${resultStatus.index}" name="source" type="hidden" value="CSIDS:LOADING(Chked:${today})" />
			</form>
		</c:when>
	</c:choose>


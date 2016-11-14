<%--

README:
        By William NG (OUHK LIB QSYS).
        Version 1.1 (Dated 23 Feb 2016)
        This JSP script bookcover_for_ajax.jsp is called by bookcover_call_ajax.jsp and try to get book cover images from multile websites in sequence.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Enable Primo Default JSTL tags. --%>
<%@ include file="/views/taglibsIncludeAll.jspf" %>

<%-- Load CSIDS Primo customized functions. --%>
<%@ include file="ouhk.jsp"%>

<%-- Read the base URLs for fetching book cover images; defined on Primo Code Table "GetIT! Tab1"  --%>
<fmt:message key="getit.customized.bookcover.baseurl.amazon" var="BookcoverBaseURLAmazon"/>
<fmt:message key="getit.customized.bookcover.baseurl.googlebook" var="BookcoverBaseURLGoogleBook"/>
<fmt:message key="getit.customized.bookcover.baseurl.anobii" var="BookcoverBaseURLAnobii"/>
<fmt:message key="getit.customized.bookcover.baseurl.bookstw" var="BookcoverBaseURLBooksTW"/>
<fmt:message key="getit.customized.bookcover.baseurl.douban" var="BookcoverBaseURLDouban"/>
<fmt:message key="getit.customized.bookcover.baseurl.findbooktw" var="BookcoverBaseURLFindbookTW"/>
<%
	String isbnStr = request.getParameter("isbn");

	//Read boook cover website variables which are obtained from loadCSIDSSiteVariables.jsp 
	String amazon = (String) pageContext.getAttribute("BookcoverBaseURLAmazon");
	String google = (String) pageContext.getAttribute("BookcoverBaseURLGoogleBook");
	String anobii = (String) pageContext.getAttribute("BookcoverBaseURLAnobii");
	String bookstw = (String) pageContext.getAttribute("BookcoverBaseURLBooksTW");
	String douban = (String) pageContext.getAttribute("BookcoverBaseURLDouban");
	String findbook = (String) pageContext.getAttribute("BookcoverBaseURLFindbookTW");

	if(isbnStr!=null){
		isbnStr = isbnStr.replaceAll(",$", "");
		String[] isbns = isbnStr.split(",");
		if(isbns.length < 1){
			isbns = null;
		} //end if
		String resultLink = "";
		try{
			//Getting the result URL of targeted book cover image; if no image is found an empty string is returned.
			//getCoverByISBN is contained in csids.jsp.
			resultLink = getCoverByISBN(isbns, amazon, google, anobii, bookstw, douban, findbook);
		} //end try
		catch(Exception ex){}

		//The result URL will be printed out to bookcover_call_ajax.jsp which will according to the result update book cover images via JavaScript.
		if(!resultLink.equals("")){
			out.println(resultLink);
		} else {
			out.println("");
		} //end if
	}//end if
%>

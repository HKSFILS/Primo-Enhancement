<%--
README:
        By William NG (OUHK LIB QSYS).
        Version 1.2 (Dated 1 Nov 2016)
        This JSP script bookcover_for_ajax.jsp is called by bookcover_call_ajax.jsp and try to get book cover images from multiple websites in sequence.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Load core Primo JSTL. --%>
<%@ include file="/views/taglibsIncludeAll.jspf" %>

<%-- Retrive CSIDS Primo Customized Code Table codes and environment varialbes. (see the JSP's source codes for descriptions.) --%>
<%@ include file="/csids/tiles/loadPrimoCodeTables.jsp"%>

<%-- Load core CSIDS functions. --%>
<%@ include file="/csids/tiles/csids.jsp"%>

<%
	String isbnStr = request.getParameter("isbn");

	//JSTL bookcoverBaseURL and noImgChecksums are obtained from loadPrimoCodeTables.jsp.
	HashMap<String,String> bookcoverBaseURL = (HashMap<String,String>) pageContext.getAttribute("bookcoverBaseURL");
	HashMap<String,String[]> noImgChecksums = (HashMap<String,String[]>) pageContext.getAttribute("noImgChecksums");

	if(isbnStr!=null){
		isbnStr = isbnStr.replaceAll(",$", "");
		String[] isbns = isbnStr.split(",");
		if(isbns.length < 1){
			isbns = null;
		} //end if
		String resultLink = "";
		try{
			//Getting the result URL of targeted book cover image; if no image is found, an empty string will be returned.
			//getCoverByISBN() is in csids.jsp.
			resultLink = getCoverByISBN(isbns, bookcoverBaseURL, noImgChecksums);
		} //end try
		catch(Exception ex){}

		//The result URL will be printed out to bookcover_call_ajax.jsp which will according to the result updates book cover images via JavaScript.
		if(!resultLink.equals("")){
			out.println(resultLink);
		} else {
			out.println("");
		} //end if
	}//end if
%>

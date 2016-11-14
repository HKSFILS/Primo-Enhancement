<%--
README:
        By William NG (OUHK LIB QSYS).
        Version 1.0 (Dated 1 Nov 2016)
        This JSP script bookcover.jsp is used to fetch book cover images via ISBN query and write out the binary images.  
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

        	        if(!resultLink.equals("")){
	                        InputStream img=getFileFromURL(resultLink);
        	                byte[] byteImg = getBytesFromInputStream(img);
				response.setContentType("image/jpeg");
				response.getOutputStream().write(byteImg);
				response.getOutputStream().close();
			} else {
				//If no image found, return a transparent PNG image.
				//String transImgUrl = "https://www.transparenttextures.com/patterns/transparent-square-tiles.png";
				String transImgUrl = "https://upload.wikimedia.org/wikipedia/commons/2/24/Transparent_Square_Tiles_Texture.png";
	                        InputStream img=getFileFromURL(transImgUrl);
        	                byte[] byteImg = getBytesFromInputStream(img);
				response.setContentType("image/jpeg");
				response.getOutputStream().write(byteImg);
				response.getOutputStream().close();
	                } //end if
		} //end try
		catch(Exception ex){out.println(ex.toString());}

	}//end if
%>

<%--
By William NG. Dated 13 Oct 2016.
This JSP fetches online an image and calculate MD5 checksums. For use with bookcover program.
This JSP "img_checkSum.jsp" is used by accessing http://primo2.csids.edu.hk/primo_library/libweb/csids/tiles/img_checkSum.jsp. 
--%>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@ page import="java.io.* ,java.awt.image.* ,javax.imageio.ImageIO ,org.apache.commons.io.IOUtils, java.security.MessageDigest" %>
Image Addr:
<form>
<input type="text" name="imgAddr" size="90%">
<input type="submit">
</form>
checksum:
<%
/* Sample no book cover images:
 * http://static.findbook.tw/images/common/icon_noimg.jpg
 * http://static.findbook.tw/image/book/9787500844976/large
 * http://static.findbook.tw/image/book/9780198001850/large
 * http://static.findbook.tw/image/book/9787807039211/large
 * https://img3.doubanio.com/mpic/s23244193.jpg
 * https://img3.doubanio.com/mpic/s25566780.jpg
 */
	String url = "";
	url = request.getParameter("imgAddr");
	InputStream img=getFileFromURL(url);
	byte[] imgBytes = getBytesFromInputStream(img);
	byte chksum=computeCheckSum(imgBytes);
	String chksumMD5=computeCheckSumMD5(imgBytes);
	out.println("Chk Sum: " + chksum);
	out.println("<BR>");
	out.println("Chk Sum MD5: " + chksumMD5);
%>


<%!
public InputStream getFileFromURL(String link){
    InputStream output=null;
    try{
        URL url=new URL(link);
            HttpURLConnection conn=(HttpURLConnection)url.openConnection();
            conn.setConnectTimeout(500);
            conn.setUseCaches(false);
                        conn.setDoInput(true);
                        conn.setDoOutput(false);
            output=conn.getInputStream();
    }catch(Exception ex){}
    return output;
}

public byte computeCheckSum(byte[] bytes){
        try{
                byte checksum=bytes[0];
                int i;
                for(i=1;i<bytes.length;i++){
                        checksum^=bytes[i];
                }
                return checksum;
        }
        catch(Exception ex){
                return 0;
        }
}

public byte[] getBytesFromInputStream(InputStream in){
    byte[] output=null;
    try{
        output=IOUtils.toByteArray(in);
    }catch(Exception ex){

    }
    return output;
}

public String computeCheckSumMD5(byte[] bytes){
        byte[] digBytes;
	String result = "";
        try{
                MessageDigest md = MessageDigest.getInstance("MD5");
                md.update(bytes);
                digBytes = md.digest();
        } //end try
        catch(Exception ex){
                return "";
        } //end catch
	StringBuffer sb = new StringBuffer();
	for (byte b : digBytes) {
		sb.append(String.format("%02x", b & 0xff));
	} //end for
	return sb.toString();
} //end computeCheckSumMD5()

%>

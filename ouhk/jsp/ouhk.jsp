<%--
README:
 Dated: 22 Jan 2016
 By William NG (OUHK LIB QSYS)
 This JSP - csids_ouhk.jsp store JAVA functions used for QESS Project CSIDS Primo.
 This JSP file is used by other JSPs by the <include file> command.
 Classes used by this JSP file must be imported by the parent JSPs first otherwise the functions here will not work.
--%>

<%@ page import="java.net.*,java.io.*,javax.xml.parsers.*,org.w3c.dom.*,org.xml.sax.*,
			java.util.*,java.util.Arrays,javax.jms.*,java.text.*, javax.mail.*, javax.mail.internet.*, javax.activation.*,
			java.io.*,java.awt.image.*,javax.imageio.ImageIO,org.apache.commons.io.IOUtils, java.util.regex.*"%>

<%!

public InputStream getFileFromURL(String link){
	InputStream output=null;
	try{
		URL url=new URL(link);
		HttpURLConnection conn=(HttpURLConnection)url.openConnection();
		conn.setConnectTimeout(1000);
		conn.setUseCaches(false);
		conn.setDoInput(true);
		conn.setDoOutput(false);
		output=conn.getInputStream();
	}catch(Exception ex){}
	return output;
} //end getFileFromURL()

public byte[] getBytesFromInputStream(InputStream in){
	byte[] output=null;
	try{
		output=IOUtils.toByteArray(in);
	}catch(Exception ex){
        
	}
	return output;
} //end getBytesFromInputStream

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
} //end computeCheckSum()

public String checkDouBanBCByISBN(String isbn, String urlS){
	try{
		String outstr = "";
		urlS = urlS.replace("{{addata/isbn}}", isbn);
		URL url = new URL(urlS);
		URLConnection urlcon = url.openConnection();
		urlcon.setConnectTimeout(1000);
		BufferedReader buffread = new BufferedReader(new InputStreamReader(urlcon.getInputStream()));
		String inputLine;
		while ((inputLine = buffread.readLine()) != null)
			outstr += inputLine;
		buffread.close();
		Pattern pattern = Pattern.compile("(http...img.*douban.*jpg)");
		Matcher matcher = pattern.matcher(outstr);
		if (matcher.find())
		{
			outstr = matcher.group(0);
			outstr = outstr.replaceAll("^.*src=\"", "");
			byte[] CheckSum_DOUBAN={21,119,-40,-52};
			boolean found=false;
			InputStream img=getFileFromURL(outstr);
			byte[] byteImg = getBytesFromInputStream(img);
		 	if(img !=null){
		 		byte chksum=computeCheckSum(byteImg);
				for(int k=0; k<CheckSum_DOUBAN.length; k++){
					if(CheckSum_DOUBAN[k]==chksum){
	 					found=true;
					} //end if
				}   //end for
				if(!found){
					return outstr;
				} //end if
			} //end if
		} //end if
	} //end try
	catch(Exception e) {}
	return "";
} //end checkDouBanBCByISBN()

public String checkBooksTWBCByISBN(String isbn, String urlS){
	try{
		String outstr = "";
		urlS = urlS.replace("{{addata/isbn}}", isbn);
		URL url = new URL(urlS);
		URLConnection urlcon = url.openConnection();
		urlcon.setConnectTimeout(1000);
		BufferedReader buffread = new BufferedReader(new InputStreamReader(urlcon.getInputStream()));
		String inputLine;
		while ((inputLine = buffread.readLine()) != null)
			outstr += inputLine;
		buffread.close();
		Pattern pattern = Pattern.compile("(http...www.book.*img.*jpg)");
		Matcher matcher = pattern.matcher(outstr);
		if (matcher.find())
		{
			byte[] CheckSum_BOOKSTW={-69, 1, -64, 0};
			boolean found = false;
			outstr = matcher.group(0);
			outstr = outstr.replaceAll("^.*getImage.*\\=", "");
			InputStream img=getFileFromURL(outstr);
			byte[] byteImg = getBytesFromInputStream(img);
	 		byte chksum=computeCheckSum(byteImg);
			for(int k=0; k<CheckSum_BOOKSTW.length; k++){
				if(CheckSum_BOOKSTW[k]==chksum){
 					found=true;
				} //end if
			}   //end for
			if(!found){
				return outstr;
			} //end if
		} //end if
	} //end try
	catch(Exception e) {}
	return "";
} //end checkBooksTWBCByISBN()

public String checkAnobiiBCByISBN(String isbn, String urlS){
	try{
		byte[] CheckSum_ANOBII={127,6,113};
		String outstr = "";
		urlS = urlS.replace("{{addata/isbn}}", isbn);
		URL url = new URL(urlS);
		URLConnection urlcon = url.openConnection();
		urlcon.setConnectTimeout(1000);
		BufferedReader buffread = new BufferedReader(new InputStreamReader(urlcon.getInputStream()));
		String inputLine;
		while ((inputLine = buffread.readLine()) != null)
			outstr += inputLine;
		buffread.close();
		Pattern pattern = Pattern.compile("(http...image.anobii.*time)");
		Matcher matcher = pattern.matcher(outstr);
		if (matcher.find())
		{
			boolean found=false;
			outstr = matcher.group(0);
			outstr = outstr.replaceAll("\\&time", "");
			InputStream img=getFileFromURL(outstr);
			byte[] byteImg = getBytesFromInputStream(img);
			byte chksum=computeCheckSum(byteImg);
                        if(byteImg.length > 2000){
				for(int k=0; k<CheckSum_ANOBII.length; k++){
					if(CheckSum_ANOBII[k]==chksum){
						found=true;
					} //end if
				}   //end for
			} //end if
			if(!found){
				return outstr;
			} //end if
		} //end if
	} //end try
	catch(Exception e) {}
	return "";
} //end checkAnobiiBCByISBN()

public String checkGoogleBCByISBN(String isbn, String urlS){
	try{
		byte[] CheckSum_GOOGLE={-46,31,8};
		String outstr = "";
		urlS = urlS.replace("{{addata/isbn}}", isbn);
		URL url = new URL(urlS);
		URLConnection urlcon = url.openConnection();
		urlcon.setRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 5.21; Mac_PowerPC)" );
		urlcon.setConnectTimeout(2000);
		BufferedReader buffread = new BufferedReader(new InputStreamReader(urlcon.getInputStream()));
		String inputLine;
		while ((inputLine = buffread.readLine()) != null)
			outstr += inputLine;
		buffread.close();
		outstr = outstr.replace("\\u0026", "&");
		Pattern pattern = Pattern.compile("(thumbnail_url.*zoom=.)");
		Matcher matcher = pattern.matcher(outstr);
		if (matcher.find())
		{
			boolean found=false;
			outstr = matcher.group(0);
			outstr = outstr.replaceAll("thumbnail_url...", "");
			InputStream img=getFileFromURL(outstr);
			byte[] byteImg = getBytesFromInputStream(img);
			byte chksum=computeCheckSum(byteImg);
			for(int k=0; k<CheckSum_GOOGLE.length; k++){
				if(CheckSum_GOOGLE[k]==chksum){
					found=true;
				} //end if
			}   //end for
			if(!found){
				return outstr;
			} //end if
		} //end if
	} //end try
	catch(Exception e) {}
	return "";
} //end checkGoogleBCByISBN()

public String checkFindBookBCByISBN(String isbn, String urlS){
	try{
		byte[] CheckSum_FINDBOOK={63,44,127,-47,-54,-34,110,63};
		boolean found=false;
		urlS = urlS.replace("{{addata/isbn}}", isbn);
		InputStream img=getFileFromURL(urlS);
		byte[] byteImg = getBytesFromInputStream(img);
	 	if(img !=null){
	 		byte chksum=computeCheckSum(byteImg);
			for(int k=0; k<CheckSum_FINDBOOK.length; k++){
				if(CheckSum_FINDBOOK[k]==chksum){
	 				found=true;
				} //end if
			}   //end for
			if(!found){
				return urlS;
			} //end if
		} //end if
		img.close();
	} //end try
	catch (Exception e) {}
	return "";
} //end checkFindBookBCByISBN()

public String checkAmazonBCByISBN(String isbn, String urlS){
	try{
		urlS = urlS.replace("{{addata/isbn}}", isbn);
		InputStream img=getFileFromURL(urlS);
		byte[] byteImg = getBytesFromInputStream(img);
		if(img != null && byteImg.length>1000){
			return urlS;
		} //end if
	} //end try
	catch (Exception e) {}
	return "";
} //end checkAmazonBCByISBN()

public String getCoverByISBN(String[] isbn, String amazon, String google, String anobii, String bookstw, String douban, String findbooktw){
	if(isbn == null){
		return "";
	} //end if
	isbn = new HashSet<String>(Arrays.asList(isbn)).toArray(new String[0]);
	String url = "";
	for(int i=0; i<isbn.length; i++){
		if(isbn[i].trim().equals("")){
			continue;
		} //end if
		isbn[i] = isbn[i].replaceAll("[^a-zA-Z0-9]", "" );
		if(url.equals("")){
			url = checkAmazonBCByISBN(isbn[i], amazon);
		} //end if
		if(url.equals("")){
			url = checkGoogleBCByISBN(isbn[i], google);
		} //end if
		if(url.equals("")){
			url = checkBooksTWBCByISBN(isbn[i], bookstw);
		} //end if
		if(url.equals("")){
			url = checkAnobiiBCByISBN(isbn[i], anobii);
		} //end if
		if(url.equals("")){
			url = checkDouBanBCByISBN(isbn[i], douban);
		} //end if
		if(url.equals("")){
			url = checkFindBookBCByISBN(isbn[i], findbooktw);
		} //end if

		if(!url.equals("")){
			return url;
		}// end if
	} //end for		
	return "";
} //end getCoverByISBN()

%>

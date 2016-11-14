<%--
README:
 Dated: 2 Nov 2016
 By William NG (OUHK LIB QSYS),  Paul CHIU (HKSYU LIB), & Geoffrey POON (OUHK ITU)
 This JSP - csids.jsp stores Java functions used for QESS Project CSIDS Primo.
 Other JSPs use the functions by the <include file> directive.
--%>

<%-- Import Java classes needed by the functions. --%>
<%@ page import="java.net.*,java.io.*,javax.xml.parsers.*,org.w3c.dom.*,org.xml.sax.*,java.lang.*,
		java.util.*,java.text.*,org.apache.commons.io.IOUtils,java.util.regex.*,
		java.security.MessageDigest,org.json.simple.*,org.json.simple.parser.*,
		org.json.simple.parser.ParseException,javax.xml.xpath.*,javax.imageio.*"
%>

<%!
/*Check Location Tab availbility status.
 *It accepts ILS record ID, sub-library (for Aleph query only), and the API query URL (for JSON or XML query) then obtains the availbility status.
 */
/*by William NG (OUHK LIB QSYS)*/
public String checkLocationTabAVAStatus(String inst_recid, String sub_lib, String urlForm){
	String instRecidArry[] = null;
	String urlStr = "";
	String outstr = "";
	String loanStatus = "";
	String loanStatuses[] = null;
	String loanDueDate = "";
	String loanDueDates[] = null;
	String loanInTransit = "";
	String loanInTransits[] = null;
	String subLibraries[] = null;
	inst_recid += "-PROMETHEUS-PROMETHEUS-PROMETHEUS-PROMETHEUS-PROMETHEUS";
	int itemCount = 0;
	instRecidArry = inst_recid.split("-");
	urlStr = urlForm + instRecidArry[1];
	try{
		URL url = new URL(urlStr);
		URLConnection urlcon = url.openConnection();
		urlcon.setConnectTimeout(2000);
		BufferedReader buffread = new BufferedReader(new InputStreamReader(urlcon.getInputStream()));
		String inputLine;
		while ((inputLine = buffread.readLine()) != null)
			outstr += inputLine;
		buffread.close();

		//Since Aleph's returned XML is not well-formed, the following line correct the misformed line.
		outstr = outstr.replace("\"xmlns:", "\" xmlns:");
		outstr = outstr.replace("\"xsi:", "\" xsi:");

		//Find out if the outstr is Json or not.
		JSONParser parser = new JSONParser();
		boolean isJson = true;
		try{
			JSONObject test = (JSONObject) parser.parse(outstr);
		} //end try
		catch(Exception e){isJson = false;}
		
		//If it is JSON, it is from HKSYU Millennium's API; and parse accordingly. If it is not Json, it should be XML Aleph's X-Service API; so parse accordingly.
		if(isJson){
			JSONObject json = (JSONObject) parser.parse(outstr);
			loanDueDate = (String) json.get("status");
			loanStatus = (String) json.get("order");
			if(loanStatus.equals("")){
				loanStatus = loanDueDate;
			} //end if
		} else {
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			InputSource is = new InputSource(new StringReader(outstr));
			Document doc = builder.parse(is);
			XPathFactory xPathfactory = XPathFactory.newInstance();
			XPath xpath = xPathfactory.newXPath();

			//Extract <AVA> tags for obtaining AVA info.
			XPathExpression expr = xpath.compile("//datafield[@tag=\"AVA\" and @ind1=\" \" and @ind2=\" \"]");
			NodeList nlist = (NodeList) expr.evaluate(doc, XPathConstants.NODESET);

			String strArry[] = new String[nlist.getLength()];
			for(int i=0; i<strArry.length; i++){
				Node node = nlist.item(i);
				NodeList nlist2 = node.getChildNodes();
				boolean inSubLib = false;
				for(int j=0; j<nlist2.getLength(); j++){
					Node node2 = nlist2.item(j);
					NamedNodeMap attrs = node2.getAttributes();
					Node node3 = attrs.getNamedItem("code");
					//Check <AVA> <sub code="E"> (sub-library) if it matches the current query.
					if(node3.getTextContent().toUpperCase().equals("B") && node2.getTextContent().toUpperCase().equals(sub_lib.toUpperCase()) ){
						inSubLib = true;
					}// end if
					//If sub-library matches, get the AVA status from <AVA> <subfield code="E">
					if(node3.getTextContent().toUpperCase().equals("E") && inSubLib){
						loanStatus += node2.getTextContent(); 
					} //end if
				} //end for
			} //end for
		} //end if
	} //end try
	catch(Exception e){return e.toString();}

	//Determine if the return status to the 3 values: 1. UNAVAILBLE, 2. MAYBEAVAILABLE, and 3. AVAILABLE for further processing.
	loanStatus = normalizeString(loanStatus);
	if(loanStatus.matches(".*DUE.*") || loanStatus.matches(".*ORDER.*")
		|| loanStatus.matches(".*ONCATALOGING.*") || loanStatus.contains("JUSTARRIVE")
		|| loanStatus.matches(".*ONHOLDSHELF.*")){
		loanStatus = "UNAVAILABLE";
	} else if(loanStatus.equals("CHECK_HOLDINGS")){
		loanStatus = "MAYBEAVAILABLE";
	} else if(loanStatus.equals("LIBUSEONLY") || loanStatus.contains("NEWBKDISPLAY") || loanStatus.contains("NOTCIRCULATE") || loanStatus.contains("EXHIBITION")){
		loanStatus = "AVAILABLE";
	} //end if
	return loanStatus;
} // end checkLocationTabAVAStatus()

/*Check availbility status from ILS by record ID.
 * The function receives a record ID string ("inst_recid"), ILS's API URL form ("urlForm"), and a mapping hashmap of AVA statuses then return the real time availbility result.
 * The ID normally is from PNX <display> <lds47> which in the format [institute]-[record id]-[type]/[format]/[status]
 * */
/*by William NG (OUHK LIB QSYS)*/
public String checkAVAStatus(String inst_recid, String urlForm, HashMap<String,String[]> avaStatuses ){
	String instRecidArry[] = null;
	String urlStr = "";
	String outstr = "";
	String loanStatus = "";
	String loanStatuses[] = null;
	String loanDueDate = "";
	String loanDueDates[] = null;
	String loanInTransit = "";
	String loanInTransits[] = null;
	String subLibraries[] = null;

	//Prevent null point exception after spliting the string.
	inst_recid += "-PROMETHEUS-PROMETHEUS-PROMETHEUS-PROMETHEUS-PROMETHEUS";
	instRecidArry = inst_recid.split("-");

	//Determine by a record ID string ("inst_recid").  If the item is in web-assibile form or for library use only,
	//"inst_recid" is from Primo PNX <display> <lds47>. The wordings "WBA", "PHY"... are pre-defined by Primo NR for <display> <lds47>.
	//return the found result (No real time availbility checking, for saving query time.). 
	if( inst_recid.contains("WBA")
		&& !inst_recid.contains("PHY")
		&& !inst_recid.contains("IPO") ) {
		return "WEBACCESS";
	} else if(instRecidArry[2].contains("JOURNAL") && !inst_recid.contains("IPO") ){
		return "LIBRARYUSEONLY";
	} //end if

	//Complete the ILS's API query url by adding the Bib record's ID.
	urlStr = urlForm + instRecidArry[1];

	try{
		URL url = new URL(urlStr);
		URLConnection urlcon = url.openConnection();
		urlcon.setConnectTimeout(2000);
		BufferedReader buffread = new BufferedReader(new InputStreamReader(urlcon.getInputStream()));
		String inputLine;
		while ((inputLine = buffread.readLine()) != null) 
			outstr += inputLine;
		buffread.close();
			
		//Find out if the outstr is Json or not.
		boolean isJson = true;
		JSONParser parser = new JSONParser();
		try{
			JSONObject test = (JSONObject) parser.parse(outstr);
		} //end try
		catch(Exception e){isJson = false;}

	
		//If it is Json, it is HKSYU Millennium's API; and parse accordingly. If it is not Json, it should be XML Aleph's X-Service API; so parse accordingly.
		if(isJson){
			//Converting to a standardized JSON array for further handling.
			outstr = outstr.replaceAll("^.*\\[", "");
			outstr = outstr.replaceAll("\\].*$", "");
			outstr = "{\"items\": [" + outstr + "] }";

			JSONObject json = (JSONObject) parser.parse(outstr);
			JSONArray jarry = (JSONArray) json.get("items");
			Iterator<JSONObject> it = jarry.iterator();
			String str = "";
			loanStatuses = new String[jarry.size()];
			loanDueDates = new String[jarry.size()];
			int i=0;
			while(it.hasNext()){
				JSONObject jItem = (JSONObject) it.next();
				String status = (String) jItem.get("status");
				String order = (String) jItem.get("order");
				if(order == null)
					order = "";
				if(status.equals(""))
					status = order;
				loanStatuses[i] = status;
				loanDueDates[i] = order;
				i++;
			} //end while
		} else {
			//Parse Aleph ILSs (OUHK,TWC,CIHE, or CHCHE) X-services XML
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			InputSource is = new InputSource(new StringReader(outstr));
			Document doc = builder.parse(is);
 			NodeList nlist = doc.getElementsByTagName("loan-status");
			if(nlist != null && nlist.getLength() == 1){
				loanStatus = nlist.item(0).getFirstChild().getNodeValue();
	 			nlist = doc.getElementsByTagName("due-date");
				loanDueDate = nlist.item(0).getFirstChild().getNodeValue();
				loanStatuses = new String[1];
				loanStatuses[0] = loanStatus;
				loanDueDates = new String[1];
				loanDueDates[0] = loanDueDate;
			} else if(nlist != null && nlist.getLength() > 1){
				loanStatuses = new String[nlist.getLength()];
				loanDueDates = new String[nlist.getLength()];
				loanInTransits =  new String[nlist.getLength()];
				subLibraries =  new String[nlist.getLength()];
				for(int i=0; i<nlist.getLength(); i++){
					loanStatuses[i] =  nlist.item(i).getFirstChild().getNodeValue();
				} //end for
	 			nlist = doc.getElementsByTagName("due-date");
				for(int i=0; i<nlist.getLength(); i++){
					loanDueDates[i] =  nlist.item(i).getFirstChild().getNodeValue();
				} //end for
	 			nlist = doc.getElementsByTagName("sub-library");
				for(int i=0; i<nlist.getLength(); i++){
					subLibraries[i] =  nlist.item(i).getFirstChild().getNodeValue();
				} //end for
			} //end if
		} //end if
	} //end try
	catch(Exception ex){}
	String loanStatusStr = "";
	int i=0;
	//Mapping from the returned AVA statuses to standardized customized summary status.
	if(loanStatuses != null){
		for(i=0; i<loanDueDates.length; i++){
			if(loanStatuses[i] != null){
			loanDueDates[i] = normalizeString(loanDueDates[i]);
			loanStatuses[i] = normalizeString(loanStatuses[i]);
			Iterator it = avaStatuses.entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry pair = (Map.Entry)it.next();
				String key = pair.getKey().toString();
				key = normalizeString(key);
				String[] values = (String[]) pair.getValue();
				for(int j=0; j<values.length; j++){
					values[j] = normalizeString(values[j]);
					if(loanStatuses[i].matches(values[j]) || loanDueDates[i].matches(values[j])
					   || loanStatuses[i].contains(values[j]) || loanDueDates[i].contains(values[j])
					){
						if(i==0){
							loanStatus = key;
						} else {
							loanStatus += "," + key;
						} //end if
					} //end if
				} //end for
			} //end while
			loanStatusStr += loanStatus;
			}
		} //end for
	} //end if

	loanStatus = normalizeString(loanStatus);
	loanDueDate = normalizeString(loanDueDate);

	//Special cases handling on condition that the bib record has more than one item records.
	if(loanStatusStr.contains("AVAILABLE") && (loanStatusStr.contains("CHECKEDOUT")
	|| loanStatusStr.contains("ONORDER")) ){
		loanStatus = "PARTLYAVAILABLE";
	} //end if
	if(loanStatusStr.contains("AVAILABLE") && loanStatusStr.contains("ORDERCANCELLED") ){
		loanStatus = "AVAILABLE";
	} //end if
	if( inst_recid.contains("WB") ){
		loanStatus += ",WEBACCESS";
	} //end if
	return loanStatus;
} //end checkAVAStatus()

/*Accept an array of availbility and reply if the title associated with the array is availabile for an ILL request.*/
/*by William NG (OUHK LIB QSYS)*/
public String calculateILLAVASummary(String avaStatuses[]){
	for(int i=0; i<avaStatuses.length; i++){
		if(avaStatuses[i].contains("AVAILABLE")){
			return "AVAILABLE";
		} //end if
	} //end for
	return "NOTAVALIBLE";
} //end calculateILLAVASummary()

/*Accept an array of availbility statues and compute a summary code in return.*/
/*by William NG (OUHK LIB QSYS)*/
public String calculateAVASummary(String recids[], String avaStatuses[], String homeLib){
	String resultStatus = "";
	boolean homeEHolding = false;
	boolean otherEHolding = false;
	boolean homeHolding = false;
	boolean otherHolding = false;
	boolean homeCheckedOut = false;
	boolean homeInProcess = false;
	boolean homeENotAva = false;
	int noAvaStatuses = 0;
	for(int i=0; i<avaStatuses.length; i++){
		int noOfSplittedStatuses = avaStatuses[i].split(",").length;
		noAvaStatuses += noOfSplittedStatuses;
	} //end for
	if(noAvaStatuses<10){
		noAvaStatuses = 10;
	} //end if
	int[] resultStatuses = new int[noAvaStatuses];

	for(int i=0; i<resultStatuses.length; i++){
		resultStatuses[i] = 0;
	} //end if

	int noOfStatuses = 0;

	//All statuses here are defined in Primo BO Code Table Calculated Availability Text entry "default.delivery.customized.ava.status.XXX".
	//The numbering (1-49) are used by programs internally.
	//Process online resource title first.
	for(int i=0; i<avaStatuses.length; i++){
		String splittedStatuses[] = avaStatuses[i].split(",");
		for(int j=0; j<splittedStatuses.length; j++){
			if(recids[i].contains(homeLib) && (recids[i].contains("EBOOK") || splittedStatuses[j].contains("WEBACCESS")) ){
				if (splittedStatuses[j].equals("ONORDER") && !homeEHolding){
					//EBook on order at home library.
					resultStatuses[noOfStatuses] = 1;
					noOfStatuses++;
					homeEHolding = true;
					homeENotAva = true;
				} else if (splittedStatuses[j].equals("INPROCESS") && !homeEHolding){
					//EBook in process at home library.
					resultStatuses[noOfStatuses] = 2;
					noOfStatuses++;
					homeEHolding = true;
					homeENotAva = true;
				} else if (homeEHolding && otherEHolding){
					//Online access for home library and other institution.
					resultStatuses[noOfStatuses] = 3;
					noOfStatuses++;
					homeEHolding = true;
				} else {
					//Online access for home libary.
					resultStatuses[noOfStatuses] = 4;
					noOfStatuses++;
					homeEHolding = true;
				} //end if
			} else if (!recids[i].contains(homeLib) && (recids[i].contains("EBOOK") ||  splittedStatuses[j].contains("WEBACCESS") )){
				if (splittedStatuses[j].contains("ONORDER") && !homeEHolding && !homeHolding){
					//EBook on order at other institution.
					resultStatuses[noOfStatuses] = 5;
					noOfStatuses++;
					otherEHolding = true;
				} else if (splittedStatuses[j].contains("INPROCESS") && !homeEHolding && !homeHolding){
					//EBook in process at other institution.
					resultStatuses[noOfStatuses] = 6;
					noOfStatuses++;
					otherEHolding = true;
				} else if (!homeEHolding && !otherEHolding){
					//Online access for other institution.
					resultStatuses[noOfStatuses] = 7;
					noOfStatuses++;
					otherEHolding = true;
				} else if (homeEHolding && !homeENotAva && !otherEHolding){
					//Online access for OUHK and other institution.
					resultStatuses[noOfStatuses] = 3;
					noOfStatuses++;
					otherEHolding = true;
				} else if (homeEHolding && !homeENotAva && !otherEHolding){
					//Online access for OUHK and other institution.
					for(int k=0; k<i; k++){
						if(resultStatuses[k] == 4){
							resultStatuses[k] = 3;
						} //end if
					}//end for
					otherEHolding = true;
				} else if (homeEHolding && homeENotAva && !otherEHolding){
					resultStatus = resultStatus.replace(".", "");
					//Online access for other institution.
					resultStatuses[noOfStatuses] = 7;
					noOfStatuses++;
					otherEHolding = true;
				} //end if
			} //end if 
		} //end for
	} //end for

	//Now process physical items.
	for(int i=0; i<recids.length; i++){
		String splittedStatuses[] = avaStatuses[i].split(",");
		for(int j=0; j<splittedStatuses.length; j++){
			//If the current record ID is held by home, doe the following.
			if(recids[i].contains(homeLib)
				&& ( ( (!recids[i].contains("EBOOK") &&  !avaStatuses[i].contains("WEBACCESS"))
				|| recids[i].contains("PHYSICAL")) || avaStatuses[i].contains("LIBRARYUSEONLY")
				|| recids[i].contains("WEALSO")  )){
				if(splittedStatuses[j].equals("AVAILABLE")){
					//Available at home library.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 20;
					noOfStatuses++;
					homeHolding = true;
				} else if(splittedStatuses[j].equals("CHECKEDOUT")){
					//Checked out at home library.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 21;
					noOfStatuses++;
					homeHolding = true;
					homeCheckedOut = true;
				} else if(splittedStatuses[j].equals("ONORDER")){
					//On order at home library.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 22;
					noOfStatuses++;
					homeHolding = true;
				} else if(splittedStatuses[j].equals("INPROCESS")){
					//In process at home library.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 23;
					noOfStatuses++;
					homeHolding = true;
				} else if(splittedStatuses[j].equals("ORDERCANCELLED")){
					//Order canceled at home libaray.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 24;
					noOfStatuses++;
					homeHolding = true;
				} else if(splittedStatuses[j].equals("PARTLYAVAILABLE")){
					//Partly available at home library.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 26;
					noOfStatuses++;
					homeHolding = true;
					homeCheckedOut = true;
				} else if(splittedStatuses[j].equals("LIBRARYUSEONLY") && j < 10){
					//Library use only at home library.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 27;
					noOfStatuses++;
					homeHolding = true;
				} else if(splittedStatuses[j].equals("MISSING")){
					//Missing at home library.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 25;
					noOfStatuses++;
					homeHolding = true;
				} else if(splittedStatuses[j].equals("ONDISPLAY")){
					//On display at home library.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 29;
					noOfStatuses++;
					homeHolding = true;
				} //end if
			} else if (!recids[i].contains(homeLib)
				&& ( (!recids[i].contains("EBOOK") &&  !avaStatuses[i].contains("WEBACCESS"))
					|| recids[i].contains("PHYSICAL")
					|| recids[i].contains("WBALSO")
					|| recids[i].contains("PHYSICAL")
					|| avaStatuses[i].contains("AVAILABLE") )){
				if(splittedStatuses[j].equals("AVAILABLE")){
					//Available at other institution.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 40;
					noOfStatuses++;
					otherHolding = true;
				} else if(splittedStatuses[j].equals("CHECKEDOUT")){
					//Checked out at other institution.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 42;
					noOfStatuses++;
				} else if(splittedStatuses[j].equals("ONORDER")){
					//On order at other institution.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 43;
					noOfStatuses++;
				} else if(splittedStatuses[j].equals("INPROCESS")){
					//In process at other institution.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 44;
					noOfStatuses++;
				} else if(splittedStatuses[j].equals("LIBRARYUSEONLY")){
					//Library use only at other institution.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 45;
					noOfStatuses++;
				} else if(splittedStatuses[j].equals("ORDERCANCELLED")){
					//Order canceled at other institution.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 46; 
					noOfStatuses++;
				} else if(splittedStatuses[j].equals("MISSING")){
					//Missing at other institution.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 47;
					noOfStatuses++;
				} else if(splittedStatuses[j].contains("PARTLYAVAILABLE")){
					//Partly available at other institution.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 48;
					noOfStatuses++;
				} else if(splittedStatuses[j].equals("ONDISPLAY")){
					//On display at other institution.
					noOfStatuses += 0;
					resultStatuses[noOfStatuses] = 49;
					noOfStatuses++;
				} //end if
			} //end if
		} //end for
	} //end for

	//Calcualte home library physical holdings.
	boolean ava = false;
	boolean eAva = false;
	boolean eNotAva = false;
	boolean notAva = false;
	boolean libOnlyAva = false;
	boolean orCan = false;
	boolean otherAva = false;
	boolean otherEAva = false;
	boolean otherNotAva = false;
	boolean otherLibOnlyAva = false;

	//Walk throught the result statuses and mark states for further calculation.
	for(int i=0; i<resultStatuses.length; i++){
		if(resultStatuses[i] == 24){
			//Order cancel at home is true.
			orCan = true;
		} //end if
		if(resultStatuses[i] == 20){
			//Available at home is true.
			ava = true;
		}else if(resultStatuses[i] == 27){
			//Lib use only at home is true.
			libOnlyAva = true;
			for(int j=0; j<resultStatuses.length; j++){
				if(resultStatuses[j] == 24){
					resultStatuses[j] = 27;
				} //end if
			} //end for
		} else if(resultStatuses[i] == 45){
			//Lib use only at other institute is true
			otherLibOnlyAva = true;
		} else if(resultStatuses[i] == 3 || resultStatuses[i] == 7){
			//E-copy at other institute is ture
			otherEAva = true;
		} else if(resultStatuses[i] == 3 || resultStatuses[i] == 4){
			//E-copy at home is ture
			eAva = true;
		} else if(resultStatuses[i] == 40 || resultStatuses[i] == 28){
			//Available at other institute is ture.
			otherAva = true;
		} else if (resultStatuses[i] > 40){
			//Unavailable at other institute is true.
			otherNotAva = true;
		} else if (resultStatuses[i] > 20  && resultStatuses[i] < 40){
			//Unavailable at home is true.
			notAva = true;
		}// end if
	} //end for

	//Treat the title as available if home institute holds two or more items some of which is available and some unavailable.
	if(ava && notAva){
		for(int i=0; i<resultStatuses.length; i++){
			if(resultStatuses[i] > 20 && resultStatuses[i] < 40){
				resultStatuses[i] = 0;
			} //end if
		} //end for	
	} //end if

	//Treat the title as available if other institute(s) hold two or more items some of which is available and some unavailable.
	if(otherAva && otherNotAva){
		for(int i=0; i<resultStatuses.length; i++){
			if(resultStatuses[i] > 40){
				resultStatuses[i] = 0;
			} //end if
		} //end for	
	} //end if

	//Change the status if both home and other institutes hold available item(s).
	if(ava && otherAva){
		for(int i=0; i<resultStatuses.length; i++){
			if(resultStatuses[i] == 20 || resultStatuses[i] == 40){
				resultStatuses[i] = 28;
			} //end if
		} //end for
	} //end if

	//Change the status if both home and other institutes hold E-copy.
	if(eAva && otherEAva){
		for(int i=0; i<resultStatuses.length; i++){
			if(resultStatuses[i] == 7 || resultStatuses[i] == 4 || resultStatuses[i] == 1){
				resultStatuses[i] = 3;
			} //end if
		} //end for
	} //end if

	//Change the status if both home and other institutets hold library-use only titles.
	if(libOnlyAva && otherLibOnlyAva){
		for(int i=0; i<resultStatuses.length; i++){
			if(resultStatuses[i] == 27 || resultStatuses[i] == 45){
				resultStatuses[i] = 30;
			} //end if
		} //end for
	} //end if

	//If an item is on order at home, remove the past cancel order record(s).
	if(orCan && resultStatuses.length > 1){
		for(int i=0; i<resultStatuses.length; i++){
			if(resultStatuses[i] == 24){
				resultStatuses[i] = 0;
			} //end if
		} //end for
	} //end if

	Arrays.sort(resultStatuses);

	//Remove duplicate values.
	for(int i=1; i<60; i++){
		boolean found = false;
		for(int j=0; j<resultStatuses.length; j++){
			if(resultStatuses[j] == i && found == false){
				found = true;
			} else if(resultStatuses[j] == i && found == true){
				resultStatuses[j] = 0;
			} //end if
		} //end for
	} //end for

	//Congregrate the results into a single string.
	resultStatus = "";
	for(int i=0; i<resultStatuses.length; i++){
		if(resultStatuses[i] != 0){
			resultStatus += String.valueOf(resultStatuses[i]) + ",";
		} //end if
	} //end for
	resultStatus = resultStatus.replaceAll(",$", "");

	return resultStatus; 
} //end calculateAVASummary()

/*Get today date.*/	
/*by William NG (OUHK LIB QSYS)*/
public String getToday(){
	Date today = new Date();
	SimpleDateFormat formatter=new SimpleDateFormat("yyyy-MM-dd");
	return formatter.format(today);
} //end getToday()

/*Internal function for normalize strings; i.e. remove unneeded characters, including spaces, and make strings to uppercase.*/
/*by William NG (OUHK LIB QSYS)*/
public String normalizeString(String str){
	str = str.toUpperCase();
	str = str.replace(" ", "");
	str = str.replace("\"", "");
	str = str.replace("/", "");
	str = str.replace("-", "");
	if(str != null){
		return str;
	} else {
		return "";
	} //end if
} //end normalizeString()

//Internal function for Remove all non-numeric characters.
/*by William NG (OUHK LIB QSYS)*/
public String extractNumeric(String str){
	str = str.replaceAll("[^0-9]", "");
	return str;
} //end extractNumeric()

//Internal function for process ISBN.
/*by William NG (OUHK LIB QSYS)*/
public String processISBN(String str){
	str = str.replaceAll("[^0-9|X|x]", "");
	return str;
} //end processISBN()

/*No use at the moment; it is supposed to write down (save) image files on the local directory (path is as below) for caching. It is not used for copyright reason.*/
/*by William NG (OUHK LIB QSYS)*/
public void writeImg(byte[] byteImg, String isbn){
	try{
		String path = "/exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/csids/Image/bookcover/"
			+ isbn + ".pic";
		File cImg = new File(path);
		if(!cImg.exists()){
			FileOutputStream oImg = new FileOutputStream(cImg);
			oImg.write(byteImg);
			oImg.flush();
			oImg.close();
		}//end if
	} //end try
	catch (Exception e){}
} //end writeImg()

//No use at the moment; for clearing all cached files under the book cover image directory
/*by William NG (OUHK LIB QSYS)*/
public boolean clearImgFolder(){
	try{
		String path = "/exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/csids/Image/bookcover";
		File folder = new File(path);
		File[] listOfFiles = folder.listFiles();
		for (int i = 0; i < listOfFiles.length; i++) {
			if (listOfFiles[i].isFile()) {
				listOfFiles[i].delete();
			} //end if
		} //end for
	} //end try
	catch (Exception e){return false;}
	return true;
} //end clearImgFolder

/*No use at the moment; it is supposed to load locally saved image files (path is as below) as book covers. It is not used for copyright reason.*/
/*by William NG (OUHK LIB QSYS)*/
public boolean haveCacheImg(String isbn){
	try{
		String path = "/exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/csids/Image/bookcover/"
			 + isbn + ".pic";
		File cImg = new File(path);
		if(cImg.exists()){
			return true;
		}//end if
	} //end try
	catch (Exception e){}
	return false;
} // haveCacheImg()

/*Get a file online.*/
/*by Geoffrey POON (OU ITU)*/
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

/*Get bytes from an online grabbed file steam.*/
/*by Geoffrey POON (OU ITU)*/
public byte[] getBytesFromInputStream(InputStream in){
	byte[] output=null;
	try{
		output=IOUtils.toByteArray(in);
	} //end try

	catch(Exception ex){}
	return output;
} //end getBytesFromInputStream

/*Compute a checksum value from bytes (files); for use to compare if two images are the same.
/*by Geoffrey POON (OU ITU)*/
/* Obsoluted.*/
public byte computeCheckSum(byte[] bytes){
	try{
		byte checksum=bytes[0];
		int i;
		for(i=1;i<bytes.length;i++){
			checksum^=bytes[i];
		} //end for
		return checksum;
	} //end try
	catch(Exception ex){return 0;}
} //end computeCheckSum()

/*Compute a checksum using MD5 digest*/
/*by William NG (OUHK LIB QSYS)*/
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

/*Check if an byte array contains an image*/
/*by William NG (OUHK LIB QSYS)*/
public boolean checkIfImage(byte[] bytes){
	try{
		ByteArrayInputStream bis = new ByteArrayInputStream(bytes);
		ImageIO.read(bis).toString(); 
	} //end try
	catch(Exception e){return false;}
	return true;
} //end checkIfImage()

/*by William NG (OUHK LIB QSYS)*/
/*by Fetch book covers online.*/
public String checkBCByISBN(String isbn, HashMap<String, String> bookcoverBaseURL, HashMap<String,String[]> noImgChecksums){

	Iterator it = bookcoverBaseURL.entrySet().iterator();
	while (it.hasNext()) {
		try{
		Map.Entry pair = (Map.Entry)it.next();
		String provider = pair.getKey().toString();
		String urlS = (String) pair.getValue();
		String[] checksums = noImgChecksums.get(provider);
		boolean noImg=false;

		/*Check "豆瓣" for book cover by ISBN*/
		if(provider.toLowerCase().equals("douban")){
			String outstr = "";
			urlS = urlS.replace("{{addata/isbn}}", isbn);
			URL url = new URL(urlS);
			URLConnection urlcon = url.openConnection();
			urlcon.setConnectTimeout(1000);
			urlcon.setRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 5.21; Mac_PowerPC)" );
			BufferedReader buffread = new BufferedReader(new InputStreamReader(urlcon.getInputStream()));
			String inputLine;
			while ((inputLine = buffread.readLine()) != null)
				outstr += inputLine;
			buffread.close();
			Pattern pattern = Pattern.compile("(http....img.*douban.*jpg)");
			Matcher matcher = pattern.matcher(outstr);
			if (matcher.find())
			{
				outstr = matcher.group(0);
				outstr = outstr.replaceAll("^.*src=\"", "");
				InputStream img=getFileFromURL(outstr);
				byte[] byteImg = getBytesFromInputStream(img);
			 	if(img !=null){
		 			String chksum=computeCheckSumMD5(byteImg);
					for(int k=0; k<checksums.length; k++){
						if(checksums[k].equals(chksum)){
	 						noImg=true;
						} //end if
					}   //end for
					if(!noImg  && checkIfImage(byteImg)){
						return outstr;
					} //end if
				} //end if
			} //end if
		} //end if

		/*Try to fetch book cover from 博客來 by ISBN.*/
		if(provider.toLowerCase().equals("bookstw")){
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
				outstr = matcher.group(0);
				outstr = outstr.replaceAll("^.*getImage.*\\=", "");
				InputStream img=getFileFromURL(outstr);
				byte[] byteImg = getBytesFromInputStream(img);
	 			String chksum=computeCheckSumMD5(byteImg);
				for(int k=0; k<checksums.length; k++){
					if(checksums[k].equals(chksum)){
 						noImg=true;
					} //end if
				}   //end for
				if(!noImg  && checkIfImage(byteImg)){
					return outstr;
				} //end if
			} //end if
		} //end if

		/*Try to fetch book cover from Anobii by ISBN.*/
		if(provider.toLowerCase().equals("anobii")){
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
				outstr = matcher.group(0);
				outstr = outstr.replaceAll("\\&time", "");
				InputStream img=getFileFromURL(outstr);
				byte[] byteImg = getBytesFromInputStream(img);
				String chksum=computeCheckSumMD5(byteImg);
	                        if(byteImg.length > 2000){
					for(int k=0; k<checksums.length; k++){
						if(checksums[k].equals(chksum)){
							noImg=true;
						} //end if
					}   //end for
				} //end if
				if(!noImg  && checkIfImage(byteImg)){
					return outstr;
				} //end if
			} //end if
		} //end if

		/*Try to fetch book cover from Google Books by ISBN.*/
		if(provider.toLowerCase().equals("google")){
			String outstr = "";
			urlS = urlS.replace("{{addata/isbn}}", isbn);
			URL url = new URL(urlS);
			URLConnection urlcon = url.openConnection();
			urlcon.setRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 5.21; Mac_PowerPC)" );
			urlcon.setConnectTimeout(1000);
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
				outstr = matcher.group(0);
				outstr = outstr.replaceAll("thumbnail_url...", "");
				InputStream img=getFileFromURL(outstr);
				byte[] byteImg = getBytesFromInputStream(img);
				String chksum=computeCheckSumMD5(byteImg);
				for(int k=0; k<checksums.length; k++){
					if(checksums[k].equals(chksum)){
						noImg=true;
					} //end if
				}   //end for
				if(!noImg  && checkIfImage(byteImg)){
					return outstr;
				} //end if
			} //end if
		} //end if

		/*Try to fetch book cover from findbook.com.tw by ISBN.*/
		if(provider.toLowerCase().equals("findbooktw")){
			//The checksum byte were obtained ealier against no-book-cover-images(can be computed by "csids/tiles/img_checkSum.jsp)"
			//byte[] CheckSum_FINDBOOK={63,44,127,-47,-54,-34,110,63}; (old checksum call)
			urlS = urlS.replace("{{addata/isbn}}", isbn);
			HttpURLConnection con = (HttpURLConnection) new URL(urlS).openConnection();
			con.setInstanceFollowRedirects(false);
			con.connect();
			String realURL = con.getHeaderField("Location");
			if(realURL.contains("icon_noimg.jpg"))
				continue;
			InputStream img=getFileFromURL(urlS);
			byte[] byteImg = getBytesFromInputStream(img);
		 	if(img !=null){
	 			String chksum=computeCheckSumMD5(byteImg);
				for(int k=0; k<checksums.length; k++){
					if(checksums[k].equals(chksum)){
	 					noImg=true;
					} //end if
				}   //end for
				if(!noImg  && checkIfImage(byteImg)){
					return urlS;
				} //end if
			} //end if
			img.close();
		} //end if

		/*Try to fetch book cover from Amazon by ISBN.*/
		if(provider.toLowerCase().equals("amazon")){
			urlS = urlS.replace("{{addata/isbn}}", isbn);
			InputStream img=getFileFromURL(urlS);
			byte[] byteImg = getBytesFromInputStream(img);
			if(img != null && byteImg.length>1000){
				byteImg = getBytesFromInputStream(img);
			 	if(img !=null){
		 			String chksum=computeCheckSumMD5(byteImg);
					for(int k=0; k<checksums.length; k++){
						if(checksums[k].equals(chksum)){
	 						noImg=true;
						} //end if
					}   //end for
					if(!noImg  && checkIfImage(byteImg)){
						return urlS;
					} //end if
				} //end if
			} //end if
		} //end if

		} //end try
		catch(Exception e){}
	} //end while

/*
 * You may implement another ebook provider here.
*/
	return "";
} //end checkBCByISBN()

/*Accept ISBNs and book cover providing websites to fetch book cover iamges in sequence.
 * The sequence is implicitly defined in the HaspMap "bookcoverBaseURL".
* An empty string is returned if NO book cover image found. */
/*by William NG (OUHK LIB QSYS)*/
public String getCoverByISBN(String[] isbn, HashMap<String, String> bookcoverBaseURL, HashMap<String,String[]> noImgChecksums){
	if(isbn == null){
		return "";
	} //end if
	isbn = new HashSet<String>(Arrays.asList(isbn)).toArray(new String[0]);
	String url = "";
	for(int i=0; i<isbn.length; i++){
		if(isbn[i].trim().equals("")){
			continue;
		} //end if
		// Trim off any non-digit characters.
		isbn[i] = isbn[i].replaceAll("[^a-zA-Z0-9]", "" );
		String str = "";
		url = checkBCByISBN(isbn[i], bookcoverBaseURL, noImgChecksums);
		//If no book cover image found.
		if(!url.equals("")){
			return url;
		}// end if
	} //end for		
	return "";
} //end getCoverByISBN()

/*No use at the moment for it lowers respond time.
//Get PNX specific values - i.e. lds48, display/title, lds46, ilsapiid, sourcerecordid, originalsourceid, recordid, lds47.
/*by William NG (OUHK LIB QSYS)*/
public HashMap<String, String[]> getPrimoRecord(String inst, String recordid){
	HashMap<String, String[]> hm = new HashMap<String, String[]>(); 
	String urlStr = "http://127.0.0.1:1701/PrimoWebServices/xservice/search/full?institution=" + inst + "&docId=" + recordid;
	String outstr = "";
	try{
		URL url = new URL(urlStr);
		URLConnection urlcon = url.openConnection();
		urlcon.setConnectTimeout(1000);
		BufferedReader buffread = new BufferedReader(new InputStreamReader(urlcon.getInputStream(), "UTF-8"));
		String inputLine = "";
		while ((inputLine = buffread.readLine()) != null) 
			outstr += inputLine;
		buffread.close();
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder = factory.newDocumentBuilder();
		InputSource is = new InputSource(new StringReader(outstr));
		Document doc = builder.parse(is);

		String pnxKeys[] = { "lds48", "title", "lds46", "ilsapiid", "sourcerecordid", "originalsourceid", "recordid", "lds47" };

		for(int j=0; j<pnxKeys.length; j++){
			NodeList nlist = doc.getElementsByTagName(pnxKeys[j]);
			String strArry[] = new String[nlist.getLength()];
			for(int i=0; i<strArry.length; i++){
				strArry[i] = nlist.item(i).getFirstChild().getNodeValue();
			} //end for
			hm.put(pnxKeys[j], strArry);
		} //end for
	} //end try
	catch(Exception e){}
	return hm;
} //end getPrimoRecord()

//Get an institute's item records and avaibility on ILS, in the form: location,callno,volume,status,inst. 
/*by William NG (OUHK LIB QSYS)*/
public String[] getBibItems(String inst, String recordid, String urlStr){
	recordid = recordid.replace(".", "");
	urlStr += recordid;
	String outstr="";
	String items[] = new String[1];
	try{
		URL url = new URL(urlStr);
		URLConnection urlcon = url.openConnection();
		urlcon.setConnectTimeout(2000);
		BufferedReader buffread = new BufferedReader(new InputStreamReader(urlcon.getInputStream(), "UTF-8"));
		String inputLine = "";
		while ((inputLine = buffread.readLine()) != null) 
			outstr += inputLine;
		buffread.close();

		//Find out if the outstr is Json or not.
		JSONParser parser = new JSONParser();
		boolean isJson = true;
		try{
			JSONObject test = (JSONObject) parser.parse(outstr);
		} //end try
		catch(Exception e){isJson = false;}

		//If the returned record is in JSON, it is from HKSYU's Millennium API. Then handle the record accordingly.
		if(isJson){
			//Standardized to a JSON array for further processing.
                        outstr = outstr.replaceAll("^.*\\[", "");
                        outstr = outstr.replaceAll("\\].*$", "");
                        outstr = "{\"items\": [" + outstr + "] }";

                        JSONObject json = (JSONObject) parser.parse(outstr);
                        JSONArray jarry = (JSONArray) json.get("items");
			items = new String[jarry.size()];
                        Iterator<JSONObject> it = jarry.iterator();
                        for(int i=0; i<items.length; i++){
                        	JSONObject jItem = (JSONObject) it.next();
                        	String status = (String) jItem.get("status");
				status = status.replace(",", "");
				status = status.trim();
                        	String volume = (String) jItem.get("volume");
				volume = volume.replace(",", "");
				volume = volume.trim();
                        	String callno = (String) jItem.get("callnumber");
				callno = callno.replace(",", "");
				callno = callno.trim();
                        	String location = (String) jItem.get("location");
				location = location.replace(",", "");
				location = location.trim();
				String conVol = "v.";
				for(int k=0; k<(4-volume.length()); k++){
					conVol += "0";
				} //end for
				volume = volume.replaceAll("v\\.", conVol);
				//Normalize AVA info.
				if(status.equals("ONSHELF") || status.equals("JUSTRETURNED")  || status.equals("AVAILABLE") ){
					status = inst + "(AVA)";
				} else {
					status = inst + "(UNAVA)";
				} //end if
				items[i] =  inst +","+ location  +","+ volume  +","+ callno  +","+ status; 
                        } //end for
		//If the returned record is not JSON, it should be XML which is from TWC, CIHE, CHCHE, or OUHK's Aleph X-Service. XML parser will be used.
		} else {
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			InputSource is = new InputSource(new StringReader(outstr));
			Document doc = builder.parse(is);
 			NodeList nlist = doc.getElementsByTagName("item-data");
			if(nlist != null){
				items = new String[nlist.getLength()];
				for(int i=0; i< nlist.getLength(); i++){
					Node node = nlist.item(i);
					String volume = "";
					String location = "";
					String callno = "";
					String status = "";
					if(node.getNodeType() == Node.ELEMENT_NODE){
						Node n1 = null;
						Element element = (Element) node;
			
						//Obtain Volume from the current record.
						NodeList nl1 = element.getElementsByTagName("z30-description");
						n1 = nl1.item(0);
						Node n2= n1.getFirstChild();
						if(n2 != null){
							volume = n2.getTextContent();
						} //end if

						//Obtain Location and Call Number from the current record.
						nl1 = element.getElementsByTagName("sub-library");
						n1 = nl1.item(0);
						location = n1.getFirstChild().getTextContent();
						nl1 = element.getElementsByTagName("location");
						n1 = nl1.item(0);
						n2 = n1.getFirstChild();
						if(n2 != null){
							callno = n2.getTextContent();
						} //end if
 
						//Obtain duedate from the current record.
						nl1 = element.getElementsByTagName("due-date");
						n1 = nl1.item(0);
						status = n1.getFirstChild().getTextContent(); 
						status = normalizeString(status);

						//Normalize Volume.
						if(volume.equals("")){
							Pattern pattern = Pattern.compile(".*(v\\.\\d+|V\\.\\d+)");
							Matcher matcher = pattern.matcher(callno);
							if(matcher.find()){
								volume = matcher.group(1);
							} else {
								volume = "NOVOL";
								status = "UNAVA";
							} //end if
						} //end if
						String conVol = "v.";
						for(int k=0; k<(4-volume.length()); k++){
							conVol += "0";
						} //end for
						volume = volume.replaceAll("v\\.", conVol);

					} //end if
					
					//Normalize AVA info.
					if(status.equals("ONSHELF") || status.equals("JUSTRETURNED")  || status.equals("AVAILABLE") ){
						status = inst + "(AVA)";
					} else {
						status = inst + "(UNAVA)";
					} //end if

					items[i] = inst + "," + location + "," + volume + "," + callno + "," + status;
				} //end for
			} //end if 
		} //end if
	} //end try
	//If any exception occurs, return an error message.
	catch(Exception e){items[0] =  inst + " record problem.,Pls try later again.,.,ERROR:,AVA" ;}
	items = new HashSet<String>(Arrays.asList(items)).toArray(new String[0]);
	return items;
} //end getBibItems()

/*Function for obtaining authentication token by conntecting Relais API before ILL form submission.*/
/*By Paul CHIU (HKSYU LIB)*/
public String prepareRelaisILLFormSubmission(String userId, String inst, HashMap<String, HashMap<String,String>> relaisFormFillInfo){
	JSONObject result = new JSONObject();
	JSONObject problem = new JSONObject();
	String barcode=userId;
        HttpURLConnection urlConnection =null;
	try {
		String authenUrl = relaisFormFillInfo.get(inst).get("authenUrl");
		String apiKey = relaisFormFillInfo.get(inst).get("apiKey");
		String userGroup = relaisFormFillInfo.get(inst).get("userGroup");
		String librarySymbol = relaisFormFillInfo.get(inst).get("librarySymbol");
                URL url = new URL(authenUrl);
               	urlConnection = (HttpURLConnection) url.openConnection();
               	urlConnection.setDoOutput(true);
                urlConnection.setRequestMethod("POST");
                urlConnection.setUseCaches(false);
                urlConnection.setConnectTimeout(10000);
                urlConnection.setReadTimeout(10000);
                urlConnection.setRequestProperty("Content-Type","application/json");
                urlConnection.connect();
                JSONObject jsonParam = new JSONObject();
                jsonParam.put("ApiKey", apiKey);
                jsonParam.put("UserGroup", userGroup);
                jsonParam.put("LibrarySymbol", librarySymbol);
                jsonParam.put("PatronId", barcode);
                OutputStreamWriter hksyuout = new   OutputStreamWriter(urlConnection.getOutputStream());
                hksyuout.write(jsonParam.toString());
                hksyuout.close();
                int HttpResult =urlConnection.getResponseCode();
                if(HttpResult ==HttpURLConnection.HTTP_OK){
	                BufferedReader br = new BufferedReader(new InputStreamReader(urlConnection.getInputStream(),"utf-8"));
                        String line = null;
                        while ((line = br.readLine()) != null) {
        	                result = (JSONObject) new JSONParser().parse(line);
                	        problem = (JSONObject) result.get("Problem");
                	} //end while
			String rStr = result.get("AuthorizationId").toString();
        	        if (problem!=null) {}
                        br.close();
			return rStr;
                } //end if
	} //end try
        catch (IOException e) {
        	e.printStackTrace();
        } catch (ParseException e) {
                e.printStackTrace();
        }finally{
        	if(urlConnection!=null)
		urlConnection.disconnect();
        } //end catch
	return ""; 
} //end prepareRelaisILLFormSubmission()
%>

function clearAdvSearchYearOUHK(){
	/******************************
	Advanced Search Year field reset to null to avoid change language error 30 Oct 2015 Start
	******************************/
	var startYearInput = document.getElementById("input_drStartYear6");
	var endYearInput = document.getElementById("input_drEndYear6");
	startYearInput.value = "";
	endYearInput.value = "";
	startYearInput.placeholder = "";
	endYearInput.placeholder = "";
	/******************************
	Advanced Search Year field reset to null Start End
	******************************/
} //end clearAdvSearchYearOUPrimo()

function hideBrowseSearchEngOUHK(){
	/******************************
	Hide "Browse Search" link under Article tab
	******************************/
	if ($('li.EXLSearchTabSelected a span').text() == "Articles") {
	$('div.EXLSearchFieldRibbonBrowseSearchLink').each(function(){   
	$(this).attr('style',"display:none;")  
	})
	} 
} //end hideBrowseSearchEngOUHK()

function hideBrowseSearchCHTWOUHK(){
	/******************************
	 * Hide "Browse Search" link under Article tab
	 * ******************************/
	if ($('li.EXLSearchTabSelected a span').text() == "搜尋文章") {
	$('div.EXLSearchFieldRibbonBrowseSearchLink').each(function(){   
	$(this).attr('style',"display:none;")  
	})
	}
} //end hideBrowseSearchCHTWOUHK()

function hideBrowseSearchZHCNOUHK(){
	/******************************
	 * Hide "Browse Search" link under Article tab
	 * ******************************/
	if ($('li.EXLSearchTabSelected a span').text() == "搜寻文章") {
	$('div.EXLSearchFieldRibbonBrowseSearchLink').each(function(){   
	$(this).attr('style',"display:none;")  
	})
	} 
} //end hideBrowseSearchCHCNOUHK()

function miscIntChangesOUHK(){

	//Below script is used for several functions
	//  -- To add Find Databases Tips in Primo
	//  -- To add EZProxy prefix for the link in Detail tab
	//  ON DOCUMENT CHANGE with modification
	//  Makes it possible to execute code when the DOM changes.
	//  Licensed under the terms of the MIT license.
	//  (c) 2010 Bal?zs Galambosi

	(function( window ) {
		var last  = +new Date();
		var delay = 100; // default delay
		// Manage event queue
		var stack = [];

		function callback() {
			var now = +new Date();
			if ( now - last > delay ) {
				for ( var i = 0; i < stack.length; i++ ) {
				stack[i]();
				} //end for
				last = now;
			} // end if
		} //end callback()

		// Public interface
		var onDomChange = function( fn, newdelay ) {
			if ( newdelay ) 
			delay = newdelay;
			stack.push( fn );
		}; //end function(fn, newdelay)

		// Naive approach for compatibility
		function naive() {
			var last  = document.getElementsByTagName('*');
			var lastlen = last.length;
			var timer = setTimeout( function check() {
			// get current state of the document
			var current = document.getElementsByTagName('*');
			var len = current.length;
			// if the length is different
			// it's fairly obvious
			if ( len != lastlen ) {
				 // just make sure the loop finishes early
				last = [];
			} // end if
			// go check every element in order
			for ( var i = 0; i < len; i++ ) {
				if ( current[i] !== last[i] ) {
					callback();
					last = current;
					lastlen = len;
					break;
				} //end if}
			} //end for
			// over, and over, and over again
			setTimeout( check, delay );
			}, delay );
		} //end native()

		// Handle DOM Change for FF 3+, Chrome
		function HandleDOM_Change () {
		} //end HandleDom_change()

		fireOnDomChange ('body', HandleDOM_Change, 100);

		function fireOnDomChange (selector, actionFunction, delay)
		{
			$(selector).bind ('DOMSubtreeModified', fireOnDelay);

			function fireOnDelay () {
				if (typeof this.Timer == "number") {
				clearTimeout (this.Timer);
				} //end if
				this.Timer  = setTimeout (  function() { fireActionFunction (); },
					delay ? delay : 333
				);
			} //end fireOnDelay()

			function fireActionFunction () {
				$(selector).unbind ('DOMSubtreeModified', fireOnDelay);
				actionFunction ();
				$(selector).bind ('DOMSubtreeModified', fireOnDelay);
			} //end fireActionFunction()
		} //end fireOnDomChange()

		// attach test events
		naive(); // for IE 5.5+

		// expose
		window.onDomChange = onDomChange;

		})( window );

	// To add EZProxy prefix for the link in Details tab
	// // To include new PC collections, append the URL to dblist below, also modify the dblist
	// // above to add EZProxy prefix to View Online tab
 
	onDomChange(function(){ 
		//To add Find Databases Tips in Primo
		if (document.getElementById('exlidFindDBRibbon') !== null ) {  
			if (document.getElementById('exlidFindDBRibbon').innerHTML.indexOf('Tips') == -1 ) {
			$('.EXLFindDBFieldRibbonFormFieldsGroup2').after('<div style="float: left;padding-left: 1.6em;padding-top:1.7em;width: 39em;"><div><b>Tips:</b> This page provides a list of databases that are subscribed by the OUHK or freely available in the Internet. You can search or browse for databases in the list below. Please click on the title to access the database, or select multiple databases to perform a combined search under “Articles” in the E-Library homepage.</div></div>');
			} //end if
		} //end if

		var dblist = new Array( "http://www.britannica.com/"); 
		$('span.EXLDetailsLinksTitle a').each(function(){  
			for ( var i = 0; i < dblist.length; i = i + 1 ) {  
				if ($(this).attr('href').indexOf(dblist[i])!==-1 && $(this).attr('href').indexOf('redirect.cgi')==-1  ) {
					var openurl = 'http://www.lib.ouhk.edu.hk/cgi-bin/redirect.cgi?url=' + $(this).attr('href');
					$(this).attr('href',openurl)
				} //end if
			} //end for
		 });
	 });
} //end miscIntChangesEngOUHK()

function changeBorrowerRecordOUHK(){
	/*******************************
	Modify the Borrower Record 
	********************************/

	/*******************************
	Modify the List of Fines display 
	in Borrower Record under Standard View
	********************************/
	 $('div.EXLMyAccountMainHeaderContent h1').each(function(){
			  if (($(this).text().indexOf('List of Fines') !== -1)  || ($(this).text().indexOf('圖書館款項') !== -1)  ) {  
			
			// To hide the "Transferred" column value
				$('td.MyAccount_FineAndFees_6').each(function(){  
				$(this).attr('style',"display:none;")
				})   
			
			// To hide the "Transferred" column label
				$('th.EXLMyAccountTableFine').each(function(){  
				if ($(this).text().indexOf('Transferred') !== -1) {
				$(this).attr('style',"display:none;")
				}
				})   
			
			// To Modify the date format for "Fine Date" column
				var months={"01":"Jan", "02":"Feb", "03":"Mar", "04":"Apr", "05":"May", "06":"Jun", "07":"Jul", "08":"Aug", "09":"Sep", "10":"Oct", "11":"Nov", "12":"Dec"}
				$("td.MyAccount_FineAndFees_3").each(function(){
					var tmp=$(this).html();
					if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
					tmp=RegExp.$2+"-"+months[RegExp.$1]+"-"+RegExp.$3;
					$(this).html(tmp);
					}
				});	
			
			  }
	 }) 

	//To Add bracket around the Fine Balance amount, e.g.(381.00)
	$('td.EXLMyAccountFinesBalanceValue').each(function(){ 
	$(this).text( "(" + $(this).text().replace("-", "") + "0)");
	})
 
	/*******************************
	Modify the Loans display 
	in Borrower Record under Standard View
	********************************/

	  $('span.EXLMyAccountMainHeaderContentSelected').each(function(){
 			  if (($(this).text().indexOf('List of Active Loans') !== -1) || ($(this).text().indexOf('List of Historic Loans') !== -1) || ($(this).text().indexOf('目前借閱中清單') !== -1) || ($(this).text().indexOf('借閱歷史清單') !== -1)   ) {  
		  
		    // To Hide "Fine" Column in List of Active Loans and List of Historic Loans
				$('th.EXLMyAccountTableFine').attr('style',"display:none;")
				$('td.MyAccount_Loans_5').attr('style',"display:none;")
			
			// To Modify the date format for "Due Date" and "Return Date" columns
				var months={"01":"Jan", "02":"Feb", "03":"Mar", "04":"Apr", "05":"May", "06":"Jun", "07":"Jul", "08":"Aug", "09":"Sep", "10":"Oct", "11":"Nov", "12":"Dec"}
				$("td.MyAccount_Loans_3").each(function(){
					var tmp=$(this).html();
					if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
					tmp=RegExp.$2+"-"+months[RegExp.$1]+"-"+RegExp.$3;
					$(this).html(tmp);
					}
				});
			  }
	 })

	/*******************************
	Modify the Details of Loan display 
	in Borrower Record under Standard View
	********************************/ 
	// To Modify the date format for "Due Date" and combine "Due Date" and "Due Time" into one row
	var months={"01":"Jan", "02":"Feb", "03":"Mar", "04":"Apr", "05":"May", "06":"Jun", "07":"Jul", "08":"Aug", "09":"Sep", "10":"Oct", "11":"Nov", "12":"Dec"}
$("#due_date > td, #loan_date > td, #last_renew_date > td").each(function(){
		var tmp=$(this).html();
		if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
			tmp=RegExp.$2+" "+months[RegExp.$1]+" "+RegExp.$3;
			$(this).html(tmp);
		}
	});
	var tmp=$("#due_hour").hide().children("td").html();
	$("#due_date").children("td").append(" at "+tmp);

// To Hide "Date of the last Renewal" if it is equaled to 00000000
	$("#last_renew_date").each(function(){
	    if($(this).children("td").html()=='00000000')$(this).hide();
	});
 
 
	/*******************************
	Modify the Fine & Fees display 
	in Borrower Record under Mobile View
	********************************/

			//To Display only "Title" and "Return Date" columns
			if ($('th.EXLMyAccountTableFine').text().indexOf('Amount (HKD)') !== -1 || $('th.EXLMyAccountTableFine').text().indexOf('總額(港幣)') !== -1) {   
				if ($('th.EXLMyAccountTableFine').css('display') == 'none') {
				$('th.EXLMyAccountTableTitle').attr('style',"width:auto;")
				$('th.EXLMyAccountTableFine').attr('style',"display:inline")
				$('td.MyAccount_FineAndFees_5').attr('style',"display:inline")
				$('th.EXLMyAccountTableDueDate').attr('style',"display:none;")
				$('td.MyAccount_FineAndFees_3').attr('style',"display:none;")
				}
			}
			

	/*******************************
	Modify the Requests display 
	in Borrower Record under Mobile View
	********************************/

			if ($('th.EXLMyAccountTableDueHour').css('display') == 'none') {   
				if (($('div.EXLMyAccountMainHeaderContent h1').text().indexOf('List of Requests') !== -1)  || ($('div.EXLMyAccountMainHeaderContent h1').text().indexOf('預約') !== -1)  ) {
				$('th.EXLMyAccountTableTitle').attr('style',"width:auto;")
				$('th.EXLMyAccountTableDueHour').attr('style',"display:table-cell;width:auto;")
				$('td.MyAccount_Requests_4').attr('style',"display:inline")
			}
			}

	/*******************************
	Script for Modify the Borrower Record ends
	********************************/			
} //end changeBorrowerRecordOUHK()


function reformatBrowseSearchOUHK(){
	/*******************************
	eformat the display of Browse Search
	nto a tab format
	*******************************/
	if ($('div.EXLSearchTabsContainer').text() == "") {  
	$('div.EXLSearchTabsContainer').html('<ul id=exlidSearchTabs class=EXLTabs><li class="EXLSearchTab EXLSearchTabSelected"><a class="EXLSearchTabTitle EXLSearchTabLABELArticles"><span style=color:#0075B0;>Browse Search</span></a></li></ul>')
	$('div.EXLSearchTabsContainer').attr('style','display:block;height:16px;')
	}
} //end reformatBrowseSearch()

function changeAdvSearchIntOUHK(){
	/*******************************
	Add ID to Start Date and End Date fields
	in Advanced Search, and use CSS to hide 
	the Day and Month fields
	********************************/
	$('div.EXLSearchFieldRibbonFormFieldsGroup2 div.EXLAdvancedSearchFormRow').each(function(index){  
	if (index == 1) {
	  $(this).attr('class','Advanced_StartDate')
	}
 
	 if (index == 2) {
	 $(this).attr('class','Advanced_EndDate')
	}
	})
} //end changeAdvSearchInt()


function changeSearchBannerOUHK(){
	/*******************************
	Replace the default Search Banner
	with Sign In instruction
	********************************/
	$("#exlidSearchBanner a").remove();
	$("#exlidSearchBanner").append("<img src=../images/sign_in.png>"); 
} //end changeSearchBannerOUHK()

function googleBookOUHK(){
	/* start of original codes
	<!-- Google Book -->
	<script type="text/javascript" src="../javascript/gbs.js"></script>
	   end of original codes */
	var x = document.createElement('script');
	x.src = '../javascript/gbs.js';
	document.getElementsByTagName("head")[0].appendChild(x);
} //end googleBookOUHK()


function forSFXChineseTitleOUHK(){
	/********************************************************
	Adding URL encode function for Chinese titles in SFX menu,
	*******************************************************/ 
	$('div.EXLTabsRibbon li.EXLMoreTab a').each(function(){
	      $(this).attr('href',encodeURI($(this).attr('href')));
		  $(this).attr('href',$(this).attr('href').replace(/\%2520/g, ' '));
		  $(this).attr('href',$(this).attr('href').replace(/\%252C/g, ' '));
		  $(this).attr('href',$(this).attr('href').replace(/\%253B/g, ' '));
	  
	})
} //end forSFXChineseTitleOUHK()

function changeLoansDetailsOUHK(){
	var onLoansDetailsPage = false;
	var exlidMyAccountMainHeader = document.getElementById("exlidMyAccountMainHeader");
	if(exlidMyAccountMainHeader != null){
		var innerHTML = exlidMyAccountMainHeader.innerHTML;
		if (innerHTML.toLowerCase().indexOf("details of loan") >= 0
			|| innerHTML.toLowerCase().indexOf("借閱明細") >= 0
			|| innerHTML.toLowerCase().indexOf("借阅历史清单") >= 0) {
			onLoansDetailsPage = true;
		} //end if
	} else {
		onLoansDetailsPage = false;
	} //end if

	if(onLoansDetailsPage){
		var table = document.getElementsByClassName("EXLMyAccountTableDetails");
		var months={"01":"Jan", "02":"Feb", "03":"Mar", "04":"Apr", "05":"May", "06":"Jun",
				"07":"Jul", "08":"Aug", "09":"Sep", "10":"Oct", "11":"Nov", "12":"Dec"}
                var months_chi={"01":"1月", "02":"2月", "03":"3月", "04":"4月", "05":"5月", "06":"6月",
                                "07":"7月", "08":"8月", "09":"9月", "10":"10月", "11":"11月", "12":"12月"}
		if(table[0] != null){
			for (var r = 0, n = table[0].rows.length; r < n; r++) {
				for (var c = 0, m = table[0].rows[r].cells.length; c < m; c++) {
				var cellValue = table[0].rows[r].cells[c].innerHTML;
					if (cellValue.toLowerCase().indexOf("due date") >= 0){
					var tmp = table[0].rows[r].cells[c+1].innerHTML
						if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
						tmp=RegExp.$2+"-"+months[RegExp.$1]+"-"+RegExp.$3;
						table[0].rows[r].cells[c+1].innerHTML = tmp;
						} //end if
						if(table[0].rows[r+1].cells[c+1].innerHTML != 0){
							table[0].rows[r].cells[c+1].innerHTML
							= table[0].rows[r].cells[c+1].innerHTML + " at " + table[0].rows[r+1].cells[c+1].innerHTML;
							table[0].deleteRow(r+1);
						} //end if
					} //end if
					if (cellValue.indexOf("到期日") >= 0){
					var tmp = table[0].rows[r].cells[c+1].innerHTML
						if(/([0-9]+)\/([0-9]+)\/([0-9]+)/.test(tmp)){
							tmp=RegExp.$2+"-"+months_chi[RegExp.$1]+"-"+RegExp.$3;
							table[0].rows[r].cells[c+1].innerHTML = tmp;
						} //end if
						if(table[0].rows[r+1].cells[c+1].innerHTML != 0){
							table[0].rows[r].cells[c+1].innerHTML
							= table[0].rows[r].cells[c+1].innerHTML + " 在 " + table[0].rows[r+1].cells[c+1].innerHTML;
							table[0].deleteRow(r+1);
						 } //end if
					} //end if
					if (cellValue.toLowerCase().indexOf("date of the last renewal") >= 0
					|| cellValue.toLowerCase().indexOf("前次續借日期") >= 0
					|| cellValue.toLowerCase().indexOf("最新续借日期") >= 0){
						if(table[0].rows[r].cells[c+1].innerHTML == 0){
							table[0].deleteRow(r);
						} //end if
					} //end if
		            	} //end for
			} //end for
		} //end if
	} //end if
} //end changeLoansDetailsOUHK()

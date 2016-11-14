/********************************************************
 ** EXL Custom Tab API (for Primo)
 **
 **	contributions, corrections and suggestions welcome.
 **
 **	for documentation and/or to comment, the wiki is here:
 ** 	http://www.exlibrisgroup.org/display/Primo/EXL+Tab+API
 ** 
 ** or email: jacob.hanan@exlibrisgroup.com
 **
 ** Modified by OUHK Library on 28 Oct 2015 - modified function(s): EXLTA_getPNX(), and EXLTA_addTabBySelector().
 **
 ****************************************************/

function EXLTA_addHeadlessTab(tabType, content, evaluator){
        $('.EXLResultTabs').each(function(){
                if(!evaluator || (evaluator && evaluator(this))){
                        var htmlcontent = '';
                        if (typeof(content)=='function'){
                                log('trying function');
                                htmlcontent = content(this);
                        }else{
                                htmlcontent = content;
                        }
                        var customTabContainer = $('<div class="'+tabType+'-Container">'+htmlcontent+'</div>');
                        
						var result = $(this).parents('.EXLResult');						
						if (!EXLTA_isFullDisplay()){//Solves 'full display' bug where container isn't added to page.
							result = result.find('.EXLSummary');
						}
						result.append(customTabContainer);
                }

        });
}

function EXLTA_addOpenTab(tabName,tabType,url,tabHandler,firstTab,evaluator){
                EXLTA_addTab(tabName,tabType,url,tabHandler,firstTab);
                $('.'+tabType).click();
}
function EXLTA_addTab(tabName,tabType,url,tabHandler,firstTab,evaluator){
        EXLTA_addTabBySelector('.EXLResultTabs',tabName,tabType,url,tabHandler,firstTab,evaluator);
}
function EXLTA_addTabBySelector(selector,tabName,tabType,url,tabHandler,firstTab,evaluator){
        $(selector).each(function(){
                //Customized by William NG (OUHK LIB QSYS) dated: 23 Oct 2015
                //                //for making the new Tab hidden by default
                var customTab = $('<li style="display:none" class="EXLResultTab '+tabType+'"><a href="'+url+'">'+tabName+'</a></li>');
                var customTabContainer = $('<div class="EXLResultTabContainer '+tabType+'-Container"></div>');
                if(!evaluator || (evaluator && evaluator(this))){
                        if (firstTab==true){
                                                $(this).find('li').removeClass('EXLResultFirstTab');
                                                $(customTab).addClass('EXLResultFirstTab');
                                                $(this).prepend(customTab);
                        }else if (firstTab==undefined || firstTab==false){
                                                $(this).find('li').removeClass('EXLResultLastTab');
                                                $(customTab).addClass('EXLResultLastTab');
                                                $(this).append(customTab);
                        }else{
                                                $(this).find(firstTab).replaceWith(customTab);
						
						}

						if (EXLTA_isFullDisplay()) {
							$(this).parents('.EXLResult').append(customTabContainer);	                        
						} else {
							$(this).parents('.EXLResult').find('.EXLSummary').append(customTabContainer);	
						}

						$('#'+$(this).attr('id')+' .'+ tabType + ' a').click(function(e){
							tabHandler(e, this, tabType, url, $(this).parents('.EXLResultTab').hasClass('EXLResultSelectedTab'));
						});
					
                }
                $(this).parents('.EXLSummary').find('.'+tabType+'-Container').hide();

        });
}

function EXLTA_wrapResultsInNativeTab(element, content,url, headerContent){
        var popOut = '<div class="EXLTabHeaderContent">'+headerContent+'</div><div class="EXLTabHeaderButtons"><ul><li class="EXLTabHeaderButtonPopout"><span></span><a href="'+url+'" target="_blank"><img src="../images/icon_popout_tab.png" /></a></li><li></li><li class="EXLTabHeaderButtonCloseTabs"><a href="#" title="hide tabs"><img src="../images/icon_close_tabs.png" alt="hide tabs"></a></li></ul></div>';
        var header = '<div class="EXLTabHeader">'+ popOut +'</div>';
        var htmlcontent = '';
        if (typeof(content)=='function'){
                log('trying function');
                htmlcontent = content(element);
        }else{
                htmlcontent = content;
        }
        var body = '<div class="EXLTabContent">'+htmlcontent+'</div>';
        return header + body;
}
function EXLTA_closeTab(element){
        if(!EXLTA_isFullDisplay()){
                $(element).parents('.EXLResultTab').removeClass('EXLResultSelectedTab');
                $(element).parents('.EXLTabsRibbon').addClass('EXLTabsRibbonClosed');
                $(element).parents('.EXLResult').find('.EXLResultTabContainer').hide();
        }
}
function EXLTA_openTab(element,tabType, content, reentrant){
        $(element).parents('.EXLTabsRibbon').removeClass('EXLTabsRibbonClosed');
        $(element).parents('.EXLResultTab').siblings().removeClass('EXLResultSelectedTab').end().addClass('EXLResultSelectedTab');
        var container = $(element).parents('.EXLResult').find('.EXLResultTabContainer').hide().end().find('.'+tabType+'-Container').show();
        if (content && !(reentrant && $(container).attr('loaded'))){
                $(container).html(content);
                if(reentrant){
                        $(container).attr('loaded','true');
                }
        }
        return container;
}

function EXLTA_iframeTabHandler(e,element,tabType,url,isSelected){
                e.preventDefault();
                if (isSelected){
                        EXLTA_closeTab(element);
                }else{
                        EXLTA_openTab(element,tabType, EXLTA_wrapResultsInNativeTab(element,'<iframe src="'+url+'"></iframe>',url,''),true);
                }
}

function EXLTA_createWidgetTabHandler(content,reentrant){
        return function(e,element,tabType,url,isSelected){
                e.preventDefault();
                if (isSelected){
                        EXLTA_closeTab(element);
                }else{
                        EXLTA_openTab(element,tabType, EXLTA_wrapResultsInNativeTab(element,content,url,''),reentrant);
                }
        };
}

function EXLTA_addLoadEvent(func){
        addLoadEvent(func);
}

function EXLTA_isFullDisplay(){
	return $('.EXLFullView').size() > 0;
}
function EXLTA_searchTerms(){
        return $('#search_field').val();
}
function EXLTA_recordId(element){
        return $(element).parents('.EXLResult').find('.EXLResultRecordId').attr('id');
}

function EXLTA_getPNX(recordId){
        // Dated: 30 Apr 2015
        // OUHK LIB corrected the unsuccessfully case of .get() - entercountered when the recordId contain a period (.).
        // Modification details 'pnx' is created and if condition is changed.
        // Original codes:
        //    var r = $('#'+recordId).get(0);
        //    if (!r.pnx){
        //    r.pnx = $.ajax({url: 'display.do',data:{doc: recordId, showPnx: true},async: false,error:function(){alert('error')}}).responseXML;
        //    }
        //    return r.pnx;
        var r = $('#'+recordId).get(0);
        var pnx;
        if (!r){
                pnx = $.ajax({url: '/primo_library/libweb/action/display.do',data:{fn: 'display', doc: recordId, showPnx: true},async: false,error:function(){log('pnx retrieval error')}}).responseXML;
        } else {
                if(r.pnx){
                        return r.pnx;
                } else {
                        pnx = $.ajax({url: '/primo_library/libweb/action/display.do',data:{fn: 'display', doc: recordId, showPnx: true},async: false,error:function(){log('pnx retrieval error')}}).responseXML;
                }
        }
        return pnx;
}

function EXLTA_getSfxLink(element){
	try{
	var href = $(element).parents('.EXLResult').find('.EXLMoreTab a').attr('href');
	var modifiedHref = href.replace(/display\.do/,"expand.do").replace(/renderMode=poppedOut/,'renderMode=prefetchXml');
	var xml = $.ajax({url: modifiedHref ,global: false,async: false,error:function(){log('sfx retrieval error')}}).responseXML;
	var htmlText = $(xml).find('element').text();
	var url = htmlText.match(/href="([^"]*)"/)[1];
	return url.replace(/&amp;/g,'&').replace(/&lt;/g,'<').replace(/&gt;/g,'>');
	}catch(errrrr){log(errrrr);}
	return undefined;	
}
function EXLTA_isbn(recordId){
        var pnx = EXLTA_getPNX(recordId);
        return $(pnx).find('isbn').eq(0).text();
}

function EXLTA_isbns(recordId){
        var pnx = EXLTA_getPNX(recordId);
		var isbns = new Array();
		$(pnx).find('isbn').each(function() {
			isbns.push($(this).text());
		});
		
		var isbn_string = isbns.join("isbn");
		
        return isbn_string;
}

//By Wiliam NG (OUHK QESS SYS) 7 Oct 2016
function EXLTA_lds46(recordId){
        var pnx = EXLTA_getPNX(recordId);
		var lds46 = new Array();
		$(pnx).find('lds46').each(function() {
			var str = $(this).text();
			str = str.replace(/,|<|>|:|\(|\)|&/g, ""); 
			str = str.replace("=", "^"); 
			str = str.replace(/ /g, "^^"); 
			lds46.push(str);
		});
		
		var lds46_string = lds46.join(",");
        return lds46_string;
} //end function EXLTA_lds46()

//By Wiliam NG (OUHK QESS SYS) 7 Oct 2016
function EXLTA_lds47(recordId){
        var pnx = EXLTA_getPNX(recordId);
		var lds47 = new Array();
		$(pnx).find('lds47').each(function() {
			var str = $(this).text().replace(/PHYSICAL.*PHYSICAL/, "PHYSICAL");
			str = str.replace(/,|<|>|:|\(|\)|&/g, ""); 
			lds47.push(str);
		});
		
		var lds47_string = lds47.join(",");
		
        return lds47_string;
} //end function EXLTA_lds47()

//By Wiliam NG (OUHK QESS SYS) 7 Oct 2016
function EXLTA_lds48(recordId){
        var pnx = EXLTA_getPNX(recordId);
		var lds48 = new Array();
		$(pnx).find('lds48').each(function() {
			lds48.push($(this).text());
		});
		
		var lds48_string = lds48.join(",");
		
        return lds48_string;
} //end function EXLTA_lds48()

function EXLTA_issn(recordId){ //contributed by Karsten Kryger Hansen
        var pnx = EXLTA_getPNX(recordId);
        return $(pnx).find('addata > issn').eq(0).text();
}

function EXLTA_year(recordId){
        var pnx = EXLTA_getPNX(recordId);
        return $(pnx).find('creationdate').eq(0).text();
}

function EXLTA_date(recordId){
        var pnx = EXLTA_getPNX(recordId);
        return $(pnx).find('addata > date').eq(0).text();
}

function EXLTA_volume(recordId){
	     var pnx = EXLTA_getPNX(recordId);
        return $(pnx).find('addata > volume').eq(0).text();
}

function EXLTA_issue(recordId){
        var pnx = EXLTA_getPNX(recordId);
        return $(pnx).find('addata > issue').eq(0).text();
}

function EXLTA_spage(recordId){
        var pnx = EXLTA_getPNX(recordId);
        return $(pnx).find('addata > spage').eq(0).text();
}

function EXLTA_epage(recordId){
        var pnx = EXLTA_getPNX(recordId);
        return $(pnx).find('addata > epage').eq(0).text();
}

function EXLTA_displaytype(recordId){
        var pnx = EXLTA_getPNX(recordId);
        return $(pnx).find('display > type').eq(0).text();
}

function EXLTA_getLang() {
	var signoutText = $("#exlidSignOut").find("a").html();

        if (startsWith(signoutText,Array('Sign in','Sign out'))) {
		return 'en_US';
        } else if (startsWith(signoutText,Array('Log ind', 'Log ud'))) {
		return 'da_DK';
	}

}

function startsWith(s,a) {
        for (x in a) {
                if (s.indexOf(a[x]) === 0) {
                        return true;
                }
        }
        return false;
}

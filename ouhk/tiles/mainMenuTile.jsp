<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/views/taglibsIncludeAll.jspf" %>
<%@ include file="/javascript/mainMenu.js" %>
<%-- do our best to make sure searchForm exists for usage by tiles in the page --%>
<!--  include setSearchForm.jspf before -->
<%@ include file="/views/include/setSearchForm.jspf"%>
<!--  include setSearchForm.jspf after   -->

<c:set var="mainViewArray" value="${sessionScope.primoView.mainMenuTileInterface.mainViewArray}"/>
<c:set var="lastUrl" value="${form.reqEncUrl}"/>
<c:set var="url" value="${fn:replace(lastUrl, '&', '%26')}"/>
<c:set var="url" value="${fn:replace(url, '/', '%2F')}"/>
<c:set var="existRemote" value="true"/>
<c:if test="${not empty searchForm}">
	<c:set var="existRemote" value="${searchForm.scp.existRemote}"/>
	<c:set var="showFindInDb" value="${searchForm.showFindInDb}"/>
</c:if>
<div id="exlidMainMenuContainer" class="EXLMainMenuContainer EXLFirstItem">
  <ul id="exlidMainMenuRibbon">
<c:if test="${showFindInDb || existRemote}">
<li id="exlidMainMenuItem0" class="EXLMainMenuItem ">
		<c:url var="searchDbURL" value="searchDB.do">
		</c:url>
		<c:set var="link_title"><fmt:message key="mainmenu.tooltip.find_db"/></c:set>
		<span>
		<c:set var="entryTab" value="1" />

		<a title="${link_title}"
		   href="#"
		   class="EXLMainMenuITEMFindInDB"
		  onclick="boomCallToRum('FindDbStat',false);openPrimoLightBox('searchDB','loadSearchDbPage','searchDbXml','');return false;">
		   <fmt:message	key='mainmenu.label.find_db' />
		</a></span>
	</li>
</c:if>
	<c:forEach items="${mainViewArray}" var="menu" varStatus="status">
		<c:set var="count" value="${status.index+1}"/>
		<c:set var="alma_atoz" value="${menu.target!='_blank'}"/>
		<%-- Dont display Tags menu in case <Display_Tags> (defined in Advanced Configuration in BO) is set to 'N' --%>
		<c:if test="${!(menu.label=='tags' && is_display_tags=='N')}">
		<li id="exlidMainMenuItem${count}" class="EXLMainMenuItem${menu.label=='atoz' && form.alma ?'Selected':((count==0)? ' EXLFirstItem':'') }">
			<%--
				Relative links will be appended with the menuitem param
				other links will be kept untouched
			 --%>
			<c:choose>
				<c:when	test="${fn:startsWith(menu.url ,'/')}">
					<c:url var="menu_link" value="${fn:escapeXml(menu.url)}">
			 			 <c:param name="menuitem" value="${status.index}"/>
					</c:url>
				</c:when>
				<c:otherwise>
					<c:url var="menu_link" value="${menu.url}"/>
				</c:otherwise>
			</c:choose>
			<c:choose>
				<c:when	test="${menu.label=='atoz'}">
			<c:set var="atoz_title"><fmt:message key="mainmenu.tooltip.${menu.label}"/></c:set>
					<span>
						<c:choose>
							<c:when	test="${menu.target=='_blank'}">	<!-- SFX A-Z should be opened in a new window -->
								<a title="A to Z"
			   href="${fn:escapeXml(menu_link)}"
			   target="popup"
			   onclick="openWindow(this.href, this.target, 'top=100,left=50,width=600,height=500,resizable=1,scrollbars=1'); return false;"
			   class="${(sessionScope.menuitem == status.index)?'selected ':''} ${(sessionScope.menuitem == status.index)?'EXLMainMenuSelected':''} EXLMainMenuITEMATOZ">
			   <fmt:message	key='mainmenu.label.${menu.label}' />
								</a>
							</c:when>
							<c:otherwise>	<!-- Alma A-Z should be opened in the current window -->
								<a title="A to Z"
								   	href="${fn:escapeXml(menu_link)}"
								 	class="${(sessionScope.menuitem == status.index)?'selected ':''} ${(sessionScope.menuitem == status.index)?'EXLMainMenuSelected':''} EXLMainMenuITEMATOZ">
								   	<fmt:message	key='mainmenu.label.${menu.label}' />
								</a>
								<c:if test="${form.alma}">
										<a
											title="<fmt:message key='alma.atoz.back_to_simple_search' />"
											href="search.do?fromTop=true&amp;fromPreferences=${form.fromPreferences}&amp;fromEshelf=${form.fromEshelf}&amp;vid=${sessionScope.vid}"
											class="${(sessionScope.menuitem == status.index)?'selected ':''} ${(sessionScope.menuitem == status.index)?'EXLMainMenuSelected':''} EXLMainMenuITEMATOZ EXLMainMenuITEMATOZClose">
											<span class="EXLMainMenuItemSelectedClose"></span>
										</a>
									</c:if>
									</c:otherwise>
						</c:choose>
					</span>
			</c:when>
			<c:otherwise>
			<c:set var="link_title"><fmt:message key='mainmenu.tooltip.${menu.label}'/></c:set>
			<c:set var="mtarget" value=""/>
			
			<c:if test="${menu.target != null}">
				<c:set var="mtarget" value='target="${menu.target}"'/>
			</c:if>
			<c:if test= "${menu.label=='tags' || menu.label=='library_search'}">
				<span><a title="${link_title}"
			   		href="${fn:escapeXml(menu_link)}&amp;fromTop=true&amp;fromPreferences=${form.fromPreferences}&amp;fromEshelf=${form.fromEshelf}&amp;vid=${sessionScope.vid}"
			   		class="${(sessionScope.menuitem == status.index)?'selected ':''} ${(sessionScope.menuitem == status.index)?'EXLMainMenuSelected ':''}EXLMainMenuITEM${menu.label}"
			   		${mtarget }>
			 		  <fmt:message	key='mainmenu.label.${menu.label}' />
				</a></span>
			</c:if>
			<c:if test= "${!(menu.label=='tags' || menu.label=='library_search')}">
				<span><a title="${link_title}"
				   href="${fn:escapeXml(menu_link)}"
				   class="${(sessionScope.menuitem == status.index)?'selected ':''} ${(sessionScope.menuitem == status.index)?'EXLMainMenuSelected ':''}EXLMainMenuITEM${menu.label}"
				   ${mtarget }>
				   <fmt:message	key='mainmenu.label.${menu.label}' />
				</a></span>
			</c:if>
				</c:otherwise>
			</c:choose>
		</li>
		</c:if>
	</c:forEach>
	<li id="exlidMainMenuItem${count+1}" class="EXLMainMenuItem EXLLastItem">
		<c:url var="helpURL" value="helpHandler.do">
			<c:param name="helpId" value="search"/>
		</c:url>

		<c:set var="link_title"><fmt:message key="mainmenu.tooltip.help"/></c:set>
		<span><a title="${link_title}"
		   href="${fn:escapeXml(helpURL)}"
		   class="EXLMainMenuITEMHelp"
		   target="popup"
		   onclick="openWindow(this.href, this.target, 'top=100,left=50,width=600,height=500,resizable=1,scrollbars=1'); return false;">
		   <fmt:message	key='mainmenu.label.help' />
		</a></span>
	</li>
  </ul>
</div>
<prm:boomerang id="FindDbStat" boomForm="${searchForm}" pageId="find-database"
				opId="databaseClick" resultDoc="${searchForm.searchResult.results[0]}" type=""
				delivery="${searchForm.delivery[0]}" noOther="true" index="${param.indx}"/>
<prm:boomerang id="CitationLinkerStat" boomForm="${searchForm}" pageId="citation-linker"
				opId="citationLinkerClick" resultDoc="${searchForm.searchResult.results[0]}" type=""
				delivery="${searchForm.delivery[0]}" noOther="true" index="${param.indx}"/>
<c:if test="${form.interfaceLangSize > 1}">
 <!--Languages menu-->
 <div class="EXLLanguagesContainer">
 <span class="EXLLanguagesLabel"><fmt:message key="mainmenu.label.language"/></span>
  <div class="EXLLanguagesMenu">
	<c:set var="lang_title"><fmt:message key="link.title.select.interface.language"/> </c:set>
    <ul id="exlidLanguages" class="EXLLanguageMenuShow EXLLanguageMenuHide "><!--remove EXLLanguageMenuHide to show menu items-->
		<c:forEach items="${form.interfacaLangs}" var="option" varStatus="status">
				<c:url var="preferencesURL" value="preferences.do?prefBackUrl=${url}%26vid=${fn:escapeXml(sessionScope.vid)}" >
					<c:param name="fn" value="change_lang"/>
 					<c:param name="vid" value="${fn:escapeXml(sessionScope.vid)}"/>
					<c:param name="prefLang" value="${option}"/>
				</c:url>
			<c:choose>
				<c:when test="${not empty sessionScope.chosenInterfaceLanguage and sessionScope.chosenInterfaceLanguage == option}">
		          <li id="exlidSelectedLanguage" class="EXLLanguageLink"><a href="#"><fmt:message key='mypref.language.option.${option}' /><img src="<fmt:message key='ui.images.resultsheadernumbers.arrowsendto'/>" alt="Show More Options"/></a></li>
				</c:when>
				<c:otherwise>
		          <li class="EXLLanguageLink EXLLanguageLinkHide"><a href="${fn:escapeXml(preferencesURL)}" class="EXLLanguageOptionLANG${option}" title="${lang_title} ${lang_name}"><fmt:message key='mypref.language.option.${option}' /></a></li>
				</c:otherwise>
			</c:choose>
		</c:forEach>
	</ul>
  </div>
</div>
</c:if>

<!-- added by ewskong on 20150226 for My Databases Tab (login) starts-->
<!--
<div id="flagForFindDbDeepLink" title="NotADeepLink"></div>
<div id="savedSelectedMyAccountTab"></div>
<div id="exlidLightbox">
<script type="text/javascript">
var str = window.location.href;
var n = str.match(/openFdb=true/g);
if (n != null){
boomCallToRum('FindDbStat',false);
var openMyDatabases = str.match(/openMyDatabases=true/g);
 if(openMyDatabases != null){
   openPrimoLightBox('searchDB','loadSearchDbPage','searchDbXml','IamDeepLinkToMyDatabases'); 
 }else{
   openPrimoLightBox('searchDB','loadSearchDbPage','searchDbXml','IamDeepLink');
 }
}
</script>
<noscript>This feature required javascript</noscript>
</div>
-->

<div id="flagForFindDbDeepLink" title="NotADeepLink"></div>
<div id="exlidLightbox">
<script type="text/javascript">
var str = window.location.href;
var n = str.match(/openFdb=true/g);
if (n != null){
boomCallToRum('FindDbStat',false);
openPrimoLightBox('searchDB','loadSearchDbPage','searchDbXml','IamDeepLink');
}
</script>
</div>
<!-- added by ewskong on 20150226 for My Databases Tab (login) ended-->

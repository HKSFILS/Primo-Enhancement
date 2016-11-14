<%@ include file="/views/taglibsIncludeAll.jspf" %>
<%@ include file="/views/include/setSearchForm.jspf"%>
<%-- Prepare functional content first, html at end of file --%>
<!-- Start of userAreaTile.jsp -->
<c:set var="primoView"  value="${sessionScope.primoView}"/>

<%--Login status variable --%>
<c:set var="loggedIn" value="${false}"/>
<c:if test="${not empty sessionScope.loggedIn and sessionScope.loggedIn==true}">
	<c:set var="loggedIn" value="${true}"/>
</c:if>

<%-- We don't use the response encoded url since this URL is used in the targetURL and there is no need to put session id on it  --%>
<c:url var="searchUrl" value="${form.reqPwd}search.do">
	<c:param name="vid" value="${primoView.id}"/>${form.fn}
</c:url>

<c:set var="userName" >
	<c:if test="${not empty sessionScope.userName}">
  			${fn:escapeXml(sessionScope.userName)}
	</c:if>
</c:set>
<c:if test="${!loggedIn}">
	<c:set var="userName">
		<fmt:message key="eshelf.user.anonymous"/>
	</c:set>
</c:if>

<c:url var="eshelfURL" value="basket.do">
 		<c:param name="${action_func}" value="display" />
 		<c:param name="fromUserArea" value="true"/>
 		<c:param name="vid" value="${primoView.id}"/>
 		<c:param name="fromPreferences" value="${form.fromPreferences}"/>
</c:url>
<c:choose>
  <c:when test="${loggedIn}">
	<c:url var="logoutUrl" value="logout.do">
  		<c:param name="loginFn" value="signout" />
  		<c:param name="vid" value="${primoView.id}"/>
  		<c:param name="targetURL" value="${fn:escapeXml(searchUrl)}"/>
	</c:url>
	<c:set var="loginTitle"><fmt:message key="eshelf.signout.title.link"/></c:set>
	<c:set var="eshelfTitle"><fmt:message key="link.title.signin.label"/></c:set>
  </c:when>
  <c:otherwise>
  	    <c:set var="errorString"><html:errors property="ESHELF_TILE_ERRORS"/></c:set>
  	<c:url var="loginUrl" value="login.do">
  		<c:param name="loginFn" value="signin" />
  		<c:param name="vid" value="${primoView.id}"/>
  		<c:param name="targetURL" value="${fn:escapeXml(form.reqEncUrl)}&amp;initializeIndex=true"/>
	</c:url>
	<c:set var="loginTitle"><fmt:message key="eshelf.signin.label1"/> <fmt:message key="eshelf.signin.label2"/></c:set>
	<c:set var="eshelfTitle"><fmt:message key="link.title.signin.label"/></c:set>
</c:otherwise>
</c:choose>

<c:url var="preferencesUrl" value="preferences.do">
 		<c:param name="${action_func}" value="init" />
 		<c:param name="vid" value="${sessionScope.vid}"/>
</c:url>

<%-- ewskong on 20150226
<c:url var="myAccountUrl" value="myAccountMenu.do">
 		<c:param name="vid" value="${sessionScope.vid}"/>
</c:url>
--%>


<%-- added by ewskong on 20150226 starts --%>
<c:url var="myAccountUrl" value="login.do">
  		<c:param name="loginFn" value="signin" />
  		<c:param name="vid" value="${fn:escapeXml(sessionScope.vid)}"/>
  		<c:param name="targetURL" value="myAccountMenu.do?vid=${fn:escapeXml(sessionScope.vid)}"/>
</c:url>
<%-- added by ewskong on 20150226 ended --%>

<c:set var="loggedInClass" value="${(loggedIn)?'EXLEShelfTileLoggedIn':'EXLEShelfTileGuest'}"/>

<%-- added by ewskong on 20150226 ended --%>

<%-- displayed content --%>
<!-- this feedback unnecesary
<c:if test="${not empty errorString}">
		<div class="EXLHighlightError">${errorString}</div>
</c:if>
-->

<prm:boomerang id="SignInStatUserArea" boomForm="${searchForm}" pageId="sign-in"
				opId="click" resultDoc="${searchForm.searchResult.results[0]}" type=""
				delivery="${searchForm.delivery[0]}" noOther="true" index="${param.indx}"/>
<prm:boomerang id="SignOutStat" boomForm="${searchForm}" pageId="sign-out"
				opId="click" resultDoc="${searchForm.searchResult.results[0]}" type=""
				delivery="${searchForm.delivery[0]}" noOther="true" index="${param.indx}"/>
								
<c:if test="${requestScope.isNewSession != null && requestScope.isNewSession eq 'true'}">
	<c:set var="ssologinRequest" value="${requestScope.ssologinRequest}"/>
	<c:if test="${ssologinRequest != null}">
		<iframe id="exlIdssoLogin" src="" height="0px" width="0px"></iframe>
	</c:if>
</c:if>
				
<ul id="exlidUserAreaRibbon" class="${loggedInClass}">
  <li id="exlidUserName" class="EXLUserName">
  	<span class="EXLUserAreaStart"></span>
  	<span class="EXLUserNameDisplay">
  		<fmt:message key="eshelf.user.greeting">
  			<fmt:param value="${userName}"></fmt:param>
  		</fmt:message></span>
  	<span class="EXLUserAreaStartRtl"></span>
  </li>
  <li id="exlidMyShelf" class="EXLMyShelf"><a href="${fn:escapeXml(eshelfURL)}"><span class="EXLMyShelfStarSelected"></span><fmt:message key="eshelf.basket.title"/></a></li>
  
  <%-- ewskong on 20150226
  <li id="exlidMyAccount" class="EXLMyAccount"><a href="${fn:escapeXml(myAccountUrl)}"><fmt:message key="menu.myaccount"/></a></li>
  --%>
  
  <%-- added by ewskong on 20150226 starts --%>
  <c:if test="${loggedIn}">
  <li id="exlidMyAccount" class="EXLMyAccount"><a href="${fn:escapeXml(myAccountUrl)}"><fmt:message key="menu.myaccount"/></a></li>
  </c:if>

  <c:if test="${not loggedIn}">
  <li id="exlidMyAccount" class="EXLMyAccount"><a href="${fn:escapeXml('login.do?loginFn=signin&targetURL=myAccountMenu.do?fn=display&fromUserArea=true&vid=OUHK&fromPreferences=false')}"><fmt:message key="menu.myaccount"/></a></li>
  </c:if>

<%-- added by ewskong on 20150226 ended --%>
  
<c:if test="${requestScope.isNewSession != null && requestScope.isNewSession eq 'true'}">
	<c:set var="ssologinRequest" value="${requestScope.ssologinRequest}"/>
	<c:if test="${ssologinRequest != null}">					
		<input type="hidden" value="${ssologinRequest}" id="exlIdssologinRequest"/>		
	</c:if>  
</c:if>
<c:set var="hideSignOutClass" value=""/>
<c:set var="hideSignInClass" value=""/>
 
<c:choose>	
	<c:when test="${loggedIn}">		  
		<c:set var="hideSignInClass" value="EXLHidden"/>	
	</c:when>
	<c:otherwise>
		<c:set var="hideSignOutClass" value="EXLHidden"/>	  			
	</c:otherwise>
</c:choose>
	<li id="exlidSignOut" class="EXLSignOut EXLLastItem ${hideSignOutClass}"><a href="${fn:escapeXml(logoutUrl)}" onclick="boomCallToRum('SignOutStat',false);"><fmt:message key="eshelf.signout.title.link"/></a></li>
	<li id="exlidSignIn" class="EXLSignOut EXLLastItem ${hideSignInClass}">
	  			<a href="${fn:escapeXml(loginUrl)}"><fmt:message key="eshelf.signin.title"/></a>
  				&nbsp;<fmt:message key="eshelf.additional.text"/>
  			</li>	  			  		

</ul>


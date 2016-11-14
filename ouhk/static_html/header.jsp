<!--NB: When translating a static html page that includes images, the link of the image must be replaced as follows:
The existing link: "../images/imageName.gif" must be changed into: "../locale/specifcLocaleCode/images/imageName.gif" where "specifcLocaleCode" represents the relevant locale of the language (e.g en_US for English USA, zh_CH for Chinese).
-->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/views/taglibsIncludeAll.jspf" %>

<table border="0" width="100%">
<tr>
<td>
<a href="http://www.ouhk.edu.hk" title="The Open University of Hong Kong">
<img src="../ouhk/images/ouhk_logo_banner.jpg" alt="logo"/></a>
</td>
<td>
<a href="http://primo2.csids.edu.hk/primo_library/libweb/action/search.do?vid=OUHK" title="E-Platform for Self Financing Institution Libraries">
<img src="../ouhk/images/SFIL_banner.jpg" alt="logo"/></a>
</td>
<tr>
</table>

<%-- Start of Customized language option; the default one is hided by CSS --%>
<c:set var="lastUrl" value="${form.reqEncUrl}"/>
<c:set var="url" value="${fn:replace(lastUrl, '&', '%26')}"/>
<c:set var="url" value="${fn:replace(url, '/', '%2F')}"/>
<div class="OUHKLanguage">
<fmt:message key="mainmenu.label.language"/>
        <c:forEach items="${form.interfacaLangs}" var="option" varStatus="status">
                <c:url var="preferencesURL" value="preferences.do?prefBackUrl=${url}%26vid=${fn:escapeXml(sessionScope.vid)}" >
                        <c:param name="fn" value="change_lang"/>
                        <c:param name="vid" value="${fn:escapeXml(sessionScope.vid)}"/>
                        <c:param name="prefLang" value="${option}"/>
                </c:url>
                <c:if test="${not empty sessionScope.chosenInterfaceLanguage and sessionScope.chosenInterfaceLanguage != option}">
                        <fmt:message key='mypref.language.option.${option}' var='langopt' />
                        <a href="${fn:escapeXml(preferencesURL)}" title="${langopt}">
                                ${langopt}
                        </a>
                        <c:if test="${!status.last}">
                        |
                        </c:if>
                </c:if>
        </c:forEach>
</div>
<%-- End of Customized language option; the default one is hided by CSS --%>

<!--
for Google Analytics Setup, ewskong on 20150304
-->
<script type="text/javascript">

  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  if (window.location.hostname == 'csids2.lib.ouhk.edu.hk') {
     ga('create', 'UA-61252308-2', 'auto');
     ga('send', 'pageview');
  }
  if (window.location.hostname == 'primo2.csids.edu.hk') {
     ga('create', 'UA-61252308-1', 'auto');
     ga('send', 'pageview');
     ga('create', 'UA-58775575-2', 'auto',{'name' : 'allsite'});
     ga('allsite.send', 'pageview');
  }

</script>


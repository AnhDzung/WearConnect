<%-- Common head include: charset, viewport, and global CSS links --%>
<%
	String assetV = application.getInitParameter("assetVersion");
	if (assetV == null || assetV.isEmpty()) {
		assetV = "20260609"; // update this to force cache busting on deploy
	}
%>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global-styles.css?v=<%=assetV%>">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/site-responsive.css?v=<%=assetV%>">

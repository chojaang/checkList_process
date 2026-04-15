<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.checklist.model.InspectionResult" %>
<%@ page import="com.checklist.model.InspectionItemResult" %>
<%
    List<InspectionResult> results = (List<InspectionResult>) request.getAttribute("results");
    if (results == null) results = new ArrayList<>();
    Integer selectedYear = (Integer) request.getAttribute("selectedYear");
    if (selectedYear == null) selectedYear = Calendar.getInstance().get(Calendar.YEAR);
%>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>연도별 결과 조회</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="h4 mb-0">Archive - Yearly View</h1>
        <div class="btn-group">
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/templates">템플릿</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/check-run">점검 실행</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/archive">결과 조회</a>
        </div>
    </div>

    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <form method="get" action="<%=request.getContextPath()%>/archive" class="row g-2 align-items-end">
                <div class="col-md-4">
                    <label class="form-label">조회 연도</label>
                    <input class="form-control" type="number" name="year" value="<%=selectedYear%>">
                </div>
                <div class="col-md-3">
                    <button class="btn btn-primary w-100" type="submit">조회</button>
                </div>
            </form>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-header"><%=selectedYear%>년 점검 결과</div>
        <div class="card-body">
            <% if (results.isEmpty()) { %>
            <p class="text-muted mb-0">해당 연도의 점검 결과가 없습니다.</p>
            <% } else {
                for (InspectionResult r : results) {
            %>
            <div class="border rounded p-3 mb-3">
                <div class="d-flex justify-content-between">
                    <div>
                        <strong><%=r.getTemplateTitle()%></strong>
                        <small class="text-muted">(템플릿 ID: <%=r.getTemplateId()%>)</small>
                    </div>
                    <small class="text-muted"><%=r.getCheckedAt()%></small>
                </div>
                <ul class="mt-2 mb-2">
                    <% for (InspectionItemResult item : r.getItemResults()) { %>
                    <li>
                        <%=item.getItemName()%> - <%=item.getStatus()%>
                        <% if (item.getNote() != null && !item.getNote().isEmpty()) { %> / <%=item.getNote()%><% } %>
                        <% if (item.getInspectionImagePath() != null && !item.getInspectionImagePath().isEmpty()) { %>
                        <br><img src="<%=item.getInspectionImagePath()%>" class="img-thumbnail mt-1" style="max-height:120px;">
                        <% } %>
                    </li>
                    <% } %>
                </ul>
                <div class="small">작성자: <%=r.getWriter()%> / 확인자: <%=r.getReviewer()%> / 결재자: <%=r.getApprover()%></div>
            </div>
            <% }} %>
        </div>
    </div>
</div>
</body>
</html>

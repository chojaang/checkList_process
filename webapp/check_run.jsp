<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.checklist.model.ChecklistTemplate" %>
<%@ page import="com.checklist.model.TemplateItem" %>
<%
    List<ChecklistTemplate> templates = (List<ChecklistTemplate>) request.getAttribute("templates");
    if (templates == null) templates = new ArrayList<>();
    ChecklistTemplate selectedTemplate = (ChecklistTemplate) request.getAttribute("selectedTemplate");
%>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>점검 실행</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="h4 mb-0">점검 실행 (Execution)</h1>
        <div class="btn-group">
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/templates">템플릿</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/check-run">점검 실행</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/archive">결과 조회</a>
        </div>
    </div>

    <div class="card shadow-sm mb-3">
        <div class="card-body">
            <form method="get" action="<%=request.getContextPath()%>/check-run" class="row g-2 align-items-end">
                <div class="col-md-8">
                    <label class="form-label">템플릿 선택</label>
                    <select class="form-select" name="templateId" required>
                        <option value="">선택하세요</option>
                        <% for (ChecklistTemplate t : templates) { %>
                        <option value="<%=t.getId()%>" <%= selectedTemplate != null && t.getId().equals(selectedTemplate.getId()) ? "selected" : "" %>><%=t.getTitle()%> (<%=t.getPeriod()%>)</option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-4">
                    <button class="btn btn-primary w-100" type="submit">템플릿 불러오기</button>
                </div>
            </form>
        </div>
    </div>

    <% if (selectedTemplate != null) { %>
    <div class="card shadow-sm">
        <div class="card-header"><%=selectedTemplate.getTitle()%> / <%=selectedTemplate.getPeriod()%></div>
        <div class="card-body">
            <form method="post" action="<%=request.getContextPath()%>/check-run" enctype="multipart/form-data">
                <input type="hidden" name="templateId" value="<%=selectedTemplate.getId()%>">

                <% for (int i = 0; i < selectedTemplate.getItems().size(); i++) {
                    TemplateItem item = selectedTemplate.getItems().get(i);
                %>
                <div class="border rounded p-3 mb-3">
                    <div class="fw-semibold"><%=item.getItemName()%></div>
                    <div class="small text-muted mb-2"><%=item.getDescription()%></div>
                    <% if (item.getReferenceImagePath() != null && !item.getReferenceImagePath().isEmpty()) { %>
                    <img src="<%=item.getReferenceImagePath()%>" class="img-thumbnail mb-2" style="max-height:130px;">
                    <% } %>

                    <div class="row g-2">
                        <div class="col-md-3">
                            <label class="form-label">점검 결과</label>
                            <select class="form-select" name="status_<%=i%>">
                                <option value="정상">이상 없음</option>
                                <option value="이상">이상 유무</option>
                            </select>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label">메모</label>
                            <input class="form-control" name="note_<%=i%>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">현장 사진</label>
                            <input type="file" class="form-control" name="inspectionImage_<%=i%>" accept="image/*">
                        </div>
                    </div>
                </div>
                <% } %>

                <h2 class="h6">결재 라인</h2>
                <div class="row g-2 mb-3">
                    <div class="col-md-4"><input class="form-control" name="writer" placeholder="작성자" required></div>
                    <div class="col-md-4"><input class="form-control" name="reviewer" placeholder="확인자" required></div>
                    <div class="col-md-4"><input class="form-control" name="approver" placeholder="결재자" required></div>
                </div>

                <button class="btn btn-success" type="submit">점검 결과 저장</button>
            </form>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.checklist.model.ChecklistTemplate" %>
<%@ page import="com.checklist.model.TemplateItem" %>
<%
    List<ChecklistTemplate> templates = (List<ChecklistTemplate>) request.getAttribute("templates");
    if (templates == null) templates = new ArrayList<>();
    ChecklistTemplate editingTemplate = (ChecklistTemplate) request.getAttribute("editingTemplate");
    boolean editMode = editingTemplate != null;
%>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Template Builder</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="h4 mb-0">동적 점검표 템플릿 빌더</h1>
        <div class="btn-group">
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/templates">템플릿</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/check-run">점검 실행</a>
            <a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/archive">결과 조회</a>
        </div>
    </div>

    <div class="row g-3">
        <div class="col-lg-7">
            <div class="card shadow-sm">
                <div class="card-header"><%= editMode ? "템플릿 수정" : "템플릿 생성" %></div>
                <div class="card-body">
                    <form method="post" action="<%=request.getContextPath()%>/templates" enctype="multipart/form-data" id="templateForm">
                        <input type="hidden" name="templateId" value="<%= editMode ? editingTemplate.getId() : "" %>">
                        <div class="row g-2">
                            <div class="col-md-8">
                                <label class="form-label">템플릿 제목</label>
                                <input class="form-control" name="title" required value="<%= editMode ? editingTemplate.getTitle() : "" %>">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">주기</label>
                                <select class="form-select" name="period">
                                    <option value="DAILY" <%= editMode && "DAILY".equals(editingTemplate.getPeriod()) ? "selected" : "" %>>일간</option>
                                    <option value="WEEKLY" <%= editMode && "WEEKLY".equals(editingTemplate.getPeriod()) ? "selected" : "" %>>주간</option>
                                    <option value="MONTHLY" <%= editMode && "MONTHLY".equals(editingTemplate.getPeriod()) ? "selected" : "" %>>월간</option>
                                </select>
                            </div>
                        </div>

                        <hr>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h2 class="h6 mb-0">점검 항목</h2>
                            <button type="button" class="btn btn-sm btn-outline-secondary" onclick="addItemRow()">+ 항목 추가</button>
                        </div>

                        <div id="itemContainer" class="d-grid gap-3">
                            <% if (editMode && editingTemplate.getItems() != null) {
                                for (int i = 0; i < editingTemplate.getItems().size(); i++) {
                                    TemplateItem item = editingTemplate.getItems().get(i);
                            %>
                            <div class="border rounded p-3 item-row">
                                <div class="mb-2">
                                    <label class="form-label">항목명</label>
                                    <input class="form-control" name="itemName" value="<%=item.getItemName()%>" required>
                                </div>
                                <div class="mb-2">
                                    <label class="form-label">항목 설명</label>
                                    <textarea class="form-control" name="itemDescription" rows="2"><%=item.getDescription()%></textarea>
                                </div>
                                <div class="mb-2">
                                    <label class="form-label">기준 사진(교체 가능)</label>
                                    <input type="file" class="form-control" name="referenceImage_<%=i%>" accept="image/*">
                                    <input type="hidden" name="existingImage_<%=i%>" value="<%=item.getReferenceImagePath()%>">
                                </div>
                                <% if (item.getReferenceImagePath() != null && !item.getReferenceImagePath().isEmpty()) { %>
                                <img src="<%=item.getReferenceImagePath()%>" class="img-thumbnail" style="max-height:120px;">
                                <% } %>
                                <button type="button" class="btn btn-sm btn-outline-danger mt-2" onclick="this.closest('.item-row').remove()">항목 삭제</button>
                            </div>
                            <% }} %>
                        </div>

                        <div class="mt-3">
                            <button class="btn btn-primary" type="submit"><%= editMode ? "템플릿 수정 저장" : "템플릿 저장" %></button>
                            <% if (editMode) { %>
                            <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/templates">취소</a>
                            <% } %>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-5">
            <div class="card shadow-sm">
                <div class="card-header">저장된 템플릿</div>
                <div class="card-body">
                    <% if (templates.isEmpty()) { %>
                    <p class="text-muted">등록된 템플릿이 없습니다.</p>
                    <% } else {
                        for (ChecklistTemplate t : templates) {
                    %>
                    <div class="border rounded p-2 mb-2">
                        <div class="fw-semibold"><%=t.getTitle()%> <span class="badge bg-secondary"><%=t.getPeriod()%></span></div>
                        <div class="small text-muted mb-2">항목 <%=t.getItems().size()%>개</div>
                        <a class="btn btn-sm btn-outline-primary" href="<%=request.getContextPath()%>/templates?editId=<%=t.getId()%>">수정</a>
                        <form class="d-inline" method="post" action="<%=request.getContextPath()%>/templates">
                            <input type="hidden" name="action" value="deleteTemplate">
                            <input type="hidden" name="templateId" value="<%=t.getId()%>">
                            <button class="btn btn-sm btn-outline-danger" type="submit">삭제</button>
                        </form>
                    </div>
                    <% }} %>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function addItemRow() {
        const index = document.querySelectorAll('.item-row').length;
        const wrapper = document.createElement('div');
        wrapper.className = 'border rounded p-3 item-row';
        wrapper.innerHTML = `
            <div class="mb-2">
                <label class="form-label">항목명</label>
                <input class="form-control" name="itemName" required>
            </div>
            <div class="mb-2">
                <label class="form-label">항목 설명</label>
                <textarea class="form-control" name="itemDescription" rows="2"></textarea>
            </div>
            <div class="mb-2">
                <label class="form-label">기준 사진</label>
                <input type="file" class="form-control" name="referenceImage_${index}" accept="image/*">
                <input type="hidden" name="existingImage_${index}" value="">
            </div>
            <button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('.item-row').remove()">항목 삭제</button>
        `;
        document.getElementById('itemContainer').appendChild(wrapper);
    }

    if (document.querySelectorAll('.item-row').length === 0) {
        addItemRow();
    }
</script>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.checklist.model.ChecklistRecord" %>
<%
    Map<String, List<String>> configMap = (Map<String, List<String>>) request.getAttribute("configMap");
    if (configMap == null) {
        configMap = new LinkedHashMap<>();
        configMap.put("DAILY", new ArrayList<>());
        configMap.put("WEEKLY", new ArrayList<>());
        configMap.put("MONTHLY", new ArrayList<>());
    }

    String selectedPeriod = (String) request.getAttribute("selectedPeriod");
    if (selectedPeriod == null || selectedPeriod.trim().isEmpty()) {
        selectedPeriod = "DAILY";
    }

    List<String> selectedItems = (List<String>) request.getAttribute("selectedItems");
    if (selectedItems == null) {
        selectedItems = new ArrayList<>();
    }

    List<ChecklistRecord> records = (List<ChecklistRecord>) request.getAttribute("records");
    if (records == null) {
        records = new ArrayList<>();
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>점검표 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-4">
    <h1 class="h3 mb-4">점검표 관리 시스템</h1>

    <div class="row g-3">
        <div class="col-lg-4">
            <div class="card shadow-sm">
                <div class="card-header">점검 항목 설정</div>
                <div class="card-body">
                    <form method="post" action="<%=request.getContextPath()%>/checklist" class="mb-3">
                        <input type="hidden" name="action" value="addItem"/>
                        <div class="mb-2">
                            <label class="form-label">주기</label>
                            <select class="form-select" name="period">
                                <option value="DAILY" <%= "DAILY".equals(selectedPeriod) ? "selected" : "" %>>일간</option>
                                <option value="WEEKLY" <%= "WEEKLY".equals(selectedPeriod) ? "selected" : "" %>>주간</option>
                                <option value="MONTHLY" <%= "MONTHLY".equals(selectedPeriod) ? "selected" : "" %>>월간</option>
                            </select>
                        </div>
                        <div class="mb-2">
                            <label class="form-label">새 항목명</label>
                            <input type="text" name="itemName" class="form-control" placeholder="예: 소화기 점검" required/>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">항목 추가</button>
                    </form>

                    <hr/>
                    <h2 class="h6">현재 항목</h2>
                    <% for (Map.Entry<String, List<String>> entry : configMap.entrySet()) { %>
                    <div class="mb-2">
                        <strong><%=entry.getKey()%></strong>
                        <ul class="small mb-0">
                            <% for (String item : entry.getValue()) { %>
                            <li><%=item%></li>
                            <% } %>
                        </ul>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card shadow-sm mb-3">
                <div class="card-header">점검표 작성</div>
                <div class="card-body">
                    <form method="post" action="<%=request.getContextPath()%>/checklist" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="submitChecklist"/>

                        <div class="row g-2">
                            <div class="col-md-6">
                                <label class="form-label">점검 제목</label>
                                <input type="text" name="checklistTitle" class="form-control" required/>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">주기</label>
                                <select class="form-select" name="period" onchange="location.href='<%=request.getContextPath()%>/checklist?period=' + this.value;">
                                    <option value="DAILY" <%= "DAILY".equals(selectedPeriod) ? "selected" : "" %>>일간</option>
                                    <option value="WEEKLY" <%= "WEEKLY".equals(selectedPeriod) ? "selected" : "" %>>주간</option>
                                    <option value="MONTHLY" <%= "MONTHLY".equals(selectedPeriod) ? "selected" : "" %>>월간</option>
                                </select>
                            </div>
                        </div>

                        <div class="table-responsive mt-3">
                            <table class="table table-bordered align-middle">
                                <thead class="table-light">
                                <tr>
                                    <th style="width:40%">항목</th>
                                    <th style="width:15%">완료</th>
                                    <th>메모</th>
                                </tr>
                                </thead>
                                <tbody>
                                <% if (selectedItems.isEmpty()) { %>
                                <tr><td colspan="3" class="text-center text-muted">해당 주기의 항목이 없습니다. 먼저 항목을 추가하세요.</td></tr>
                                <% } else {
                                    for (int i = 0; i < selectedItems.size(); i++) {
                                        String item = selectedItems.get(i);
                                %>
                                <tr>
                                    <td><%=item%></td>
                                    <td class="text-center">
                                        <input class="form-check-input" type="checkbox" name="item_done_<%=i%>" value="Y"/>
                                    </td>
                                    <td>
                                        <input type="text" class="form-control" name="item_comment_<%=i%>" placeholder="특이사항 입력"/>
                                    </td>
                                </tr>
                                <% }} %>
                                </tbody>
                            </table>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">종합 메모</label>
                            <textarea name="overallNote" class="form-control" rows="3"></textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">사진 업로드</label>
                            <input class="form-control" type="file" name="photo" accept="image/*"/>
                        </div>

                        <h2 class="h6">결재 라인</h2>
                        <div class="row g-2 mb-3">
                            <div class="col-md-4">
                                <label class="form-label">작성자</label>
                                <input type="text" class="form-control" name="writer" required/>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">확인자</label>
                                <input type="text" class="form-control" name="reviewer" required/>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">결재자</label>
                                <input type="text" class="form-control" name="approver" required/>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-success">점검표 저장</button>
                    </form>
                </div>
            </div>

            <div class="card shadow-sm">
                <div class="card-header">최근 점검표</div>
                <div class="card-body">
                    <% if (records.isEmpty()) { %>
                    <p class="text-muted mb-0">저장된 점검표가 없습니다.</p>
                    <% } else {
                        for (ChecklistRecord r : records) {
                    %>
                    <div class="border rounded p-3 mb-3">
                        <div class="d-flex justify-content-between">
                            <div>
                                <strong><%=r.getChecklistTitle()%></strong>
                                <span class="badge bg-secondary"><%=r.getPeriodType()%></span>
                            </div>
                            <small class="text-muted"><%=r.getCreatedAt()%></small>
                        </div>
                        <ul class="mt-2 mb-2">
                            <% for (ChecklistRecord.ItemResult itemResult : r.getResults()) { %>
                            <li>
                                <%=itemResult.getItemName()%> -
                                <%=itemResult.isDone() ? "완료" : "미완료"%>
                                <% if (itemResult.getComment() != null && !itemResult.getComment().isEmpty()) { %>
                                (<%=itemResult.getComment()%>)
                                <% } %>
                            </li>
                            <% } %>
                        </ul>
                        <div class="small">
                            작성자: <%=r.getWriter()%> / 확인자: <%=r.getReviewer()%> / 결재자: <%=r.getApprover()%>
                        </div>
                        <% if (r.getOverallNote() != null && !r.getOverallNote().isEmpty()) { %>
                        <div class="small mt-1">메모: <%=r.getOverallNote()%></div>
                        <% } %>
                        <% if (r.getImagePath() != null && !r.getImagePath().isEmpty()) { %>
                        <img src="<%=r.getImagePath()%>" alt="첨부 이미지" class="img-fluid rounded mt-2" style="max-height: 220px;"/>
                        <% } %>
                    </div>
                    <% }} %>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>

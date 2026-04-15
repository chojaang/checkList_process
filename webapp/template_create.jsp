<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.checklist.model.ChecklistTemplate" %>
<%@ page import="com.checklist.model.TemplateItem" %>
<%
    List<ChecklistTemplate> templates = (List<ChecklistTemplate>) request.getAttribute("templates");
    if (templates == null) templates = new ArrayList<>();
    ChecklistTemplate editingTemplate = (ChecklistTemplate) request.getAttribute("editingTemplate");
    boolean editMode = editingTemplate != null;
    String initialSheetJson = editMode && editingTemplate.getSheetJson() != null ? editingTemplate.getSheetJson() : "";
%>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Template Builder</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        #sheetTable td {
            min-width: 100px;
            height: 58px;
            vertical-align: top;
            cursor: cell;
            position: relative;
        }
        #sheetTable td.selected { outline: 2px solid #0d6efd; outline-offset: -2px; }
        #sheetTable td .cell-text { font-size: .9rem; white-space: pre-wrap; }
        #sheetTable td img { max-width: 96px; max-height: 56px; border-radius: 6px; margin-top: 4px; display:block; }
    </style>
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
        <div class="col-lg-8">
            <div class="card shadow-sm mb-3">
                <div class="card-header"><%= editMode ? "템플릿 수정" : "템플릿 생성" %></div>
                <div class="card-body">
                    <form method="post" action="<%=request.getContextPath()%>/templates" enctype="multipart/form-data" id="templateForm">
                        <input type="hidden" name="templateId" value="<%= editMode ? editingTemplate.getId() : "" %>">
                        <input type="hidden" name="sheetJson" id="sheetJsonInput" value="">

                        <div class="row g-2 mb-2">
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

                        <div class="alert alert-secondary small mb-3">
                            <strong>엑셀형 셀 편집기:</strong> 드래그로 셀 선택 → 병합, 텍스트/이미지 입력 → 저장 시 JSON으로 보존됩니다.
                        </div>

                        <div class="d-flex flex-wrap gap-2 mb-2">
                            <button type="button" class="btn btn-sm btn-outline-primary" onclick="mergeSelection()">선택 셀 병합</button>
                            <button type="button" class="btn btn-sm btn-outline-secondary" onclick="unmergeSelection()">병합 해제</button>
                            <button type="button" class="btn btn-sm btn-outline-dark" onclick="setCellText()">선택 셀 내용 입력</button>
                            <button type="button" class="btn btn-sm btn-outline-dark" onclick="openImagePicker()">선택 셀 이미지 넣기</button>
                            <button type="button" class="btn btn-sm btn-outline-danger" onclick="clearCell()">선택 셀 비우기</button>
                        </div>
                        <input id="cellImageInput" type="file" accept="image/*" hidden>

                        <div class="table-responsive mb-3">
                            <table class="table table-bordered bg-white" id="sheetTable"></table>
                        </div>

                        <hr>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h2 class="h6 mb-0">(선택) 항목형 입력</h2>
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
                                    <input class="form-control" name="itemName" value="<%=item.getItemName()%>">
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

        <div class="col-lg-4">
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
                        <div class="small text-muted mb-2">
                            셀 템플릿: <%= (t.getSheetJson() != null && !t.getSheetJson().isEmpty()) ? "사용" : "미사용" %>
                        </div>
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
    const ROWS = 8;
    const COLS = 6;
    const rawSheet = `<%=initialSheetJson.replace("`", "\\`")%>`;

    let sheetState = createDefaultState();
    let startCell = null;
    let selectedCells = [];

    function createDefaultState() {
        const cells = [];
        for (let r = 0; r < ROWS; r++) {
            const row = [];
            for (let c = 0; c < COLS; c++) {
                row.push({
                    text: '',
                    image: '',
                    rowspan: 1,
                    colspan: 1,
                    hidden: false
                });
            }
            cells.push(row);
        }
        return { rows: ROWS, cols: COLS, cells };
    }

    function loadState() {
        if (!rawSheet || rawSheet.trim().length === 0) return;
        try {
            const parsed = JSON.parse(rawSheet);
            if (parsed && parsed.cells) {
                sheetState = parsed;
            }
        } catch (e) {
            console.warn('sheet json parse error', e);
        }
    }

    function renderSheet() {
        const table = document.getElementById('sheetTable');
        table.innerHTML = '';

        for (let r = 0; r < sheetState.rows; r++) {
            const tr = document.createElement('tr');
            for (let c = 0; c < sheetState.cols; c++) {
                const cell = sheetState.cells[r][c];
                if (cell.hidden) continue;

                const td = document.createElement('td');
                td.dataset.r = r;
                td.dataset.c = c;
                td.rowSpan = cell.rowspan || 1;
                td.colSpan = cell.colspan || 1;
                td.innerHTML = `<div class="cell-text"></div>`;
                td.querySelector('.cell-text').textContent = cell.text || '';

                if (cell.image) {
                    const img = document.createElement('img');
                    img.src = cell.image;
                    td.appendChild(img);
                }

                td.addEventListener('mousedown', onCellDown);
                td.addEventListener('mouseover', onCellOver);
                tr.appendChild(td);
            }
            table.appendChild(tr);
        }
        repaintSelection();
    }

    function onCellDown(e) {
        const td = e.currentTarget;
        startCell = { r: Number(td.dataset.r), c: Number(td.dataset.c) };
        selectedCells = [startCell];
        repaintSelection();
    }

    function onCellOver(e) {
        if (!startCell || (e.buttons !== 1)) return;
        const td = e.currentTarget;
        const end = { r: Number(td.dataset.r), c: Number(td.dataset.c) };
        selectedCells = getRectSelection(startCell, end);
        repaintSelection();
    }

    document.addEventListener('mouseup', () => startCell = null);

    function getRectSelection(a, b) {
        const minR = Math.min(a.r, b.r), maxR = Math.max(a.r, b.r);
        const minC = Math.min(a.c, b.c), maxC = Math.max(a.c, b.c);
        const selected = [];
        for (let r = minR; r <= maxR; r++) {
            for (let c = minC; c <= maxC; c++) {
                if (!sheetState.cells[r][c].hidden) selected.push({ r, c });
            }
        }
        return selected;
    }

    function repaintSelection() {
        document.querySelectorAll('#sheetTable td').forEach(td => td.classList.remove('selected'));
        selectedCells.forEach(pos => {
            const td = document.querySelector(`#sheetTable td[data-r="${pos.r}"][data-c="${pos.c}"]`);
            if (td) td.classList.add('selected');
        });
    }

    function mergeSelection() {
        if (selectedCells.length < 2) return;
        const minR = Math.min(...selectedCells.map(v => v.r));
        const maxR = Math.max(...selectedCells.map(v => v.r));
        const minC = Math.min(...selectedCells.map(v => v.c));
        const maxC = Math.max(...selectedCells.map(v => v.c));

        const master = sheetState.cells[minR][minC];
        master.rowspan = (maxR - minR + 1);
        master.colspan = (maxC - minC + 1);

        for (let r = minR; r <= maxR; r++) {
            for (let c = minC; c <= maxC; c++) {
                if (r === minR && c === minC) continue;
                sheetState.cells[r][c].hidden = true;
                sheetState.cells[r][c].rowspan = 1;
                sheetState.cells[r][c].colspan = 1;
                sheetState.cells[r][c].text = '';
                sheetState.cells[r][c].image = '';
            }
        }

        selectedCells = [{ r: minR, c: minC }];
        renderSheet();
    }

    function unmergeSelection() {
        if (selectedCells.length !== 1) return;
        const { r, c } = selectedCells[0];
        const master = sheetState.cells[r][c];
        const rowspan = master.rowspan || 1;
        const colspan = master.colspan || 1;

        for (let rr = r; rr < r + rowspan; rr++) {
            for (let cc = c; cc < c + colspan; cc++) {
                sheetState.cells[rr][cc].hidden = false;
                sheetState.cells[rr][cc].rowspan = 1;
                sheetState.cells[rr][cc].colspan = 1;
            }
        }
        renderSheet();
    }

    function setCellText() {
        if (selectedCells.length !== 1) return;
        const { r, c } = selectedCells[0];
        const current = sheetState.cells[r][c].text || '';
        const next = prompt('셀 내용을 입력하세요.', current);
        if (next === null) return;
        sheetState.cells[r][c].text = next;
        renderSheet();
    }

    function openImagePicker() {
        if (selectedCells.length !== 1) return;
        document.getElementById('cellImageInput').click();
    }

    document.getElementById('cellImageInput').addEventListener('change', function (e) {
        if (selectedCells.length !== 1) return;
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function(evt) {
            const { r, c } = selectedCells[0];
            sheetState.cells[r][c].image = evt.target.result;
            renderSheet();
        };
        reader.readAsDataURL(file);
        e.target.value = '';
    });

    function clearCell() {
        if (selectedCells.length !== 1) return;
        const { r, c } = selectedCells[0];
        sheetState.cells[r][c].text = '';
        sheetState.cells[r][c].image = '';
        renderSheet();
    }

    function addItemRow() {
        const index = document.querySelectorAll('.item-row').length;
        const wrapper = document.createElement('div');
        wrapper.className = 'border rounded p-3 item-row';
        wrapper.innerHTML = `
            <div class="mb-2">
                <label class="form-label">항목명</label>
                <input class="form-control" name="itemName">
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

    document.getElementById('templateForm').addEventListener('submit', function() {
        document.getElementById('sheetJsonInput').value = JSON.stringify(sheetState);
    });

    loadState();
    renderSheet();
</script>
</body>
</html>

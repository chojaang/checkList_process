package com.checklist.servlet;

import com.checklist.model.ChecklistRecord;
import com.checklist.store.ChecklistStore;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "ChecklistServlet", urlPatterns = {"/checklist"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 20 * 1024 * 1024
)
public class ChecklistServlet extends HttpServlet {
    private ChecklistStore store;

    @Override
    public void init() {
        String dataRoot = getServletContext().getRealPath("/WEB-INF/data");
        Path dataPath;
        if (dataRoot == null) {
            dataPath = Paths.get(System.getProperty("java.io.tmpdir"), "checklist-data");
        } else {
            dataPath = Paths.get(dataRoot);
        }

        store = new ChecklistStore(dataPath.resolve("checklist-data.json"));
        store.load();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String selectedPeriod = req.getParameter("period");
        if (selectedPeriod == null || selectedPeriod.isBlank()) {
            selectedPeriod = "DAILY";
        }

        Map<String, List<String>> configMap = store.getConfigMap();
        req.setAttribute("configMap", configMap);
        req.setAttribute("selectedPeriod", selectedPeriod);
        req.setAttribute("selectedItems", store.getItems(selectedPeriod));
        req.setAttribute("records", store.getRecords());

        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        if ("addItem".equals(action)) {
            handleAddItem(req);
        } else if ("submitChecklist".equals(action)) {
            handleSubmitChecklist(req);
        }

        resp.sendRedirect(req.getContextPath() + "/checklist?period=" + safe(req.getParameter("period"), "DAILY"));
    }

    private void handleAddItem(HttpServletRequest req) {
        String period = safe(req.getParameter("period"), "DAILY");
        String item = req.getParameter("itemName");
        if (item != null && !item.isBlank()) {
            store.addChecklistItem(period, item.trim());
        }
    }

    private void handleSubmitChecklist(HttpServletRequest req) throws IOException, ServletException {
        String period = safe(req.getParameter("period"), "DAILY");
        List<String> selectedItems = store.getItems(period);

        ChecklistRecord record = new ChecklistRecord();
        record.setPeriodType(period);
        record.setChecklistTitle(req.getParameter("checklistTitle"));
        record.setWriter(req.getParameter("writer"));
        record.setReviewer(req.getParameter("reviewer"));
        record.setApprover(req.getParameter("approver"));
        record.setOverallNote(req.getParameter("overallNote"));

        List<ChecklistRecord.ItemResult> results = new ArrayList<>();
        for (int i = 0; i < selectedItems.size(); i++) {
            String itemName = selectedItems.get(i);
            String doneParam = req.getParameter("item_done_" + i);
            String comment = req.getParameter("item_comment_" + i);
            results.add(new ChecklistRecord.ItemResult(itemName, "Y".equals(doneParam), safe(comment, "")));
        }
        record.setResults(results);

        Part imagePart = req.getPart("photo");
        String storedPath = saveImage(imagePart, req);
        record.setImagePath(storedPath);

        store.saveRecord(record);
    }

    private String saveImage(Part imagePart, HttpServletRequest req) throws IOException {
        if (imagePart == null || imagePart.getSize() == 0) {
            return "";
        }

        String originalFile = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
        String ext = "";
        int dotIdx = originalFile.lastIndexOf('.');
        if (dotIdx >= 0) {
            ext = originalFile.substring(dotIdx);
        }

        String newFileName = UUID.randomUUID() + ext;
        String uploadRoot = getServletContext().getRealPath("/uploads");
        File uploadDir;
        if (uploadRoot == null) {
            uploadDir = new File(System.getProperty("java.io.tmpdir"), "checklist-uploads");
        } else {
            uploadDir = new File(uploadRoot);
        }

        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        File saveFile = new File(uploadDir, newFileName);
        imagePart.write(saveFile.getAbsolutePath());

        return req.getContextPath() + "/uploads/" + newFileName;
    }

    private String safe(String value, String fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }
        return value;
    }
}

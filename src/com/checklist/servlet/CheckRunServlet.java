package com.checklist.servlet;

import com.checklist.model.ChecklistTemplate;
import com.checklist.model.InspectionItemResult;
import com.checklist.model.InspectionResult;
import com.checklist.model.TemplateItem;
import com.checklist.repository.FileJsonRepository;
import com.checklist.util.AppFilePaths;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@WebServlet(urlPatterns = {"/check-run"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 70 * 1024 * 1024)
public class CheckRunServlet extends HttpServlet {
    private final FileJsonRepository repository = new FileJsonRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<ChecklistTemplate> templates = repository.loadTemplates(getServletContext());
        req.setAttribute("templates", templates);

        String templateId = req.getParameter("templateId");
        if (templateId != null && !templateId.isBlank()) {
            Optional<ChecklistTemplate> selected = repository.findTemplate(getServletContext(), templateId);
            selected.ifPresent(template -> req.setAttribute("selectedTemplate", template));
        }

        req.getRequestDispatcher("/check_run.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String templateId = req.getParameter("templateId");
        Optional<ChecklistTemplate> selected = repository.findTemplate(getServletContext(), templateId);
        if (selected.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/check-run");
            return;
        }

        ChecklistTemplate template = selected.get();
        InspectionResult result = new InspectionResult();
        result.setId(UUID.randomUUID().toString());
        result.setTemplateId(template.getId());
        result.setTemplateTitle(template.getTitle());
        result.setCheckedAt(LocalDateTime.now().toString());
        result.setWriter(req.getParameter("writer"));
        result.setReviewer(req.getParameter("reviewer"));
        result.setApprover(req.getParameter("approver"));

        List<InspectionItemResult> itemResults = new ArrayList<>();
        List<TemplateItem> templateItems = template.getItems();

        for (int i = 0; i < templateItems.size(); i++) {
            TemplateItem templateItem = templateItems.get(i);
            InspectionItemResult itemResult = new InspectionItemResult();
            itemResult.setItemName(templateItem.getItemName());
            itemResult.setStatus(req.getParameter("status_" + i));
            itemResult.setNote(req.getParameter("note_" + i));

            Part imagePart = req.getPart("inspectionImage_" + i);
            itemResult.setInspectionImagePath(saveInspectionImage(imagePart, req));
            itemResults.add(itemResult);
        }

        result.setItemResults(itemResults);
        int year = LocalDate.now().getYear();
        repository.saveResultByYear(getServletContext(), year, result);

        resp.sendRedirect(req.getContextPath() + "/archive?year=" + year);
    }

    private String saveInspectionImage(Part part, HttpServletRequest req) throws IOException {
        if (part == null || part.getSize() == 0) {
            return "";
        }

        String original = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        int dot = original.lastIndexOf('.');
        String ext = dot >= 0 ? original.substring(dot) : "";

        String newName = UUID.randomUUID() + ext;
        File uploadDir = AppFilePaths.uploadDir(getServletContext(), "inspection");
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        File saveFile = new File(uploadDir, newName);
        part.write(saveFile.getAbsolutePath());
        return req.getContextPath() + "/uploads/inspection/" + newName;
    }
}

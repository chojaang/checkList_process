package com.checklist.servlet;

import com.checklist.model.ChecklistTemplate;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@WebServlet(urlPatterns = {"/templates"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class TemplateServlet extends HttpServlet {
    private final FileJsonRepository repository = new FileJsonRepository();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String editId = req.getParameter("editId");
        if (editId != null && !editId.isBlank()) {
            Optional<ChecklistTemplate> editing = repository.findTemplate(getServletContext(), editId);
            editing.ifPresent(template -> req.setAttribute("editingTemplate", template));
        }

        req.setAttribute("templates", repository.loadTemplates(getServletContext()));
        req.getRequestDispatcher("/template_create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("deleteTemplate".equals(action)) {
            repository.deleteTemplate(getServletContext(), req.getParameter("templateId"));
            resp.sendRedirect(req.getContextPath() + "/templates");
            return;
        }

        String templateId = req.getParameter("templateId");
        if (templateId == null || templateId.isBlank()) {
            templateId = UUID.randomUUID().toString();
        }

        ChecklistTemplate template = new ChecklistTemplate();
        template.setId(templateId);
        template.setTitle(req.getParameter("title"));
        template.setPeriod(req.getParameter("period"));

        String[] itemNames = req.getParameterValues("itemName");
        String[] descriptions = req.getParameterValues("itemDescription");
        List<TemplateItem> items = new ArrayList<>();

        if (itemNames != null) {
            for (int i = 0; i < itemNames.length; i++) {
                if (itemNames[i] == null || itemNames[i].isBlank()) {
                    continue;
                }
                TemplateItem item = new TemplateItem();
                item.setItemName(itemNames[i]);
                item.setDescription(descriptions != null && descriptions.length > i ? descriptions[i] : "");

                String existingImage = req.getParameter("existingImage_" + i);
                Part referenceImage = req.getPart("referenceImage_" + i);
                String imagePath = saveUpload(referenceImage, "reference", existingImage, req);
                item.setReferenceImagePath(imagePath);

                items.add(item);
            }
        }

        template.setItems(items);
        repository.upsertTemplate(getServletContext(), template);
        resp.sendRedirect(req.getContextPath() + "/templates");
    }

    private String saveUpload(Part part, String type, String existingPath, HttpServletRequest req) throws IOException {
        if (part == null || part.getSize() == 0) {
            return existingPath == null ? "" : existingPath;
        }

        String original = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        int dot = original.lastIndexOf('.');
        String ext = dot >= 0 ? original.substring(dot) : "";

        String newName = UUID.randomUUID() + ext;
        File uploadDir = AppFilePaths.uploadDir(getServletContext(), type);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        File saveFile = new File(uploadDir, newName);
        part.write(saveFile.getAbsolutePath());
        return req.getContextPath() + "/uploads/" + type + "/" + newName;
    }
}

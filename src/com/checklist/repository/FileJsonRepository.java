package com.checklist.repository;

import com.checklist.model.ChecklistTemplate;
import com.checklist.model.InspectionResult;
import com.checklist.util.AppFilePaths;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletContext;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class FileJsonRepository {

    public synchronized List<ChecklistTemplate> loadTemplates(ServletContext context) {
        Path path = AppFilePaths.templatesFile(context);
        if (!Files.exists(path)) {
            return new ArrayList<>();
        }

        try {
            String body = Files.readString(path, StandardCharsets.UTF_8);
            JSONObject root = new JSONObject(body);
            JSONArray arr = root.optJSONArray("templates");
            List<ChecklistTemplate> list = new ArrayList<>();
            if (arr != null) {
                for (int i = 0; i < arr.length(); i++) {
                    list.add(ChecklistTemplate.fromJson(arr.getJSONObject(i)));
                }
            }
            return list;
        } catch (IOException e) {
            throw new RuntimeException("templates.json 읽기 오류", e);
        }
    }

    public synchronized void saveTemplates(ServletContext context, List<ChecklistTemplate> templates) {
        JSONObject root = new JSONObject();
        JSONArray arr = new JSONArray();
        for (ChecklistTemplate template : templates) {
            arr.put(template.toJson());
        }
        root.put("templates", arr);

        Path path = AppFilePaths.templatesFile(context);
        try {
            Files.createDirectories(path.getParent());
            Files.writeString(path, root.toString(2), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException("templates.json 저장 오류", e);
        }
    }

    public synchronized void upsertTemplate(ServletContext context, ChecklistTemplate template) {
        List<ChecklistTemplate> templates = loadTemplates(context);
        int index = -1;
        for (int i = 0; i < templates.size(); i++) {
            if (templates.get(i).getId().equals(template.getId())) {
                index = i;
                break;
            }
        }

        if (index >= 0) {
            templates.set(index, template);
        } else {
            templates.add(template);
        }
        saveTemplates(context, templates);
    }

    public synchronized void deleteTemplate(ServletContext context, String templateId) {
        List<ChecklistTemplate> templates = loadTemplates(context);
        templates.removeIf(t -> t.getId().equals(templateId));
        saveTemplates(context, templates);
    }

    public synchronized Optional<ChecklistTemplate> findTemplate(ServletContext context, String templateId) {
        return loadTemplates(context).stream().filter(t -> t.getId().equals(templateId)).findFirst();
    }

    public synchronized void saveResultByYear(ServletContext context, int year, InspectionResult result) {
        Path path = AppFilePaths.resultFileByYear(context, year);
        JSONObject root = new JSONObject();
        JSONArray arr = new JSONArray();

        if (Files.exists(path)) {
            try {
                root = new JSONObject(Files.readString(path, StandardCharsets.UTF_8));
                arr = root.optJSONArray("results");
                if (arr == null) {
                    arr = new JSONArray();
                }
            } catch (IOException e) {
                throw new RuntimeException("결과 파일 읽기 오류", e);
            }
        }

        arr.put(result.toJson());
        root.put("year", year);
        root.put("results", arr);

        try {
            Files.createDirectories(path.getParent());
            Files.writeString(path, root.toString(2), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException("결과 파일 저장 오류", e);
        }
    }

    public synchronized List<InspectionResult> findResultsByYear(ServletContext context, int year) {
        Path path = AppFilePaths.resultFileByYear(context, year);
        if (!Files.exists(path)) {
            return new ArrayList<>();
        }

        try {
            JSONObject root = new JSONObject(Files.readString(path, StandardCharsets.UTF_8));
            JSONArray arr = root.optJSONArray("results");
            List<InspectionResult> list = new ArrayList<>();
            if (arr != null) {
                for (int i = 0; i < arr.length(); i++) {
                    list.add(InspectionResult.fromJson(arr.getJSONObject(i)));
                }
            }
            return list;
        } catch (IOException e) {
            throw new RuntimeException("결과 조회 오류", e);
        }
    }
}

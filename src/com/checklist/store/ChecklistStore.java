package com.checklist.store;

import com.checklist.model.ChecklistRecord;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class ChecklistStore {
    private final Map<String, List<String>> configMap = new LinkedHashMap<>();
    private final List<ChecklistRecord> records = new ArrayList<>();
    private final Path jsonPath;

    public ChecklistStore(Path jsonPath) {
        this.jsonPath = jsonPath;
        configMap.put("DAILY", new ArrayList<>());
        configMap.put("WEEKLY", new ArrayList<>());
        configMap.put("MONTHLY", new ArrayList<>());
    }

    public synchronized void addChecklistItem(String period, String itemName) {
        configMap.computeIfAbsent(period, k -> new ArrayList<>()).add(itemName);
        persist();
    }

    public synchronized Map<String, List<String>> getConfigMap() {
        Map<String, List<String>> copy = new LinkedHashMap<>();
        for (Map.Entry<String, List<String>> entry : configMap.entrySet()) {
            copy.put(entry.getKey(), new ArrayList<>(entry.getValue()));
        }
        return Collections.unmodifiableMap(copy);
    }

    public synchronized List<String> getItems(String period) {
        return new ArrayList<>(configMap.getOrDefault(period, Collections.emptyList()));
    }

    public synchronized void saveRecord(ChecklistRecord record) {
        if (record.getId() == null || record.getId().isEmpty()) {
            record.setId(UUID.randomUUID().toString());
        }
        if (record.getCreatedAt() == null) {
            record.setCreatedAt(LocalDateTime.now());
        }
        records.add(0, record);
        persist();
    }

    public synchronized List<ChecklistRecord> getRecords() {
        return new ArrayList<>(records);
    }

    public synchronized void load() {
        if (!Files.exists(jsonPath)) {
            return;
        }
        try {
            String content = Files.readString(jsonPath, StandardCharsets.UTF_8);
            JSONObject root = new JSONObject(content);

            configMap.clear();
            configMap.put("DAILY", new ArrayList<>());
            configMap.put("WEEKLY", new ArrayList<>());
            configMap.put("MONTHLY", new ArrayList<>());

            JSONArray configs = root.optJSONArray("configs");
            if (configs != null) {
                for (int i = 0; i < configs.length(); i++) {
                    JSONObject cfg = configs.getJSONObject(i);
                    String period = cfg.optString("period", "DAILY");
                    String item = cfg.optString("item", "");
                    if (!item.isBlank()) {
                        configMap.computeIfAbsent(period, k -> new ArrayList<>()).add(item);
                    }
                }
            }

            records.clear();
            JSONArray rowArray = root.optJSONArray("records");
            if (rowArray != null) {
                for (int i = 0; i < rowArray.length(); i++) {
                    JSONObject row = rowArray.getJSONObject(i);
                    ChecklistRecord record = new ChecklistRecord();
                    record.setId(row.optString("id"));
                    record.setPeriodType(row.optString("periodType"));
                    record.setChecklistTitle(row.optString("title"));
                    record.setWriter(row.optString("writer"));
                    record.setReviewer(row.optString("reviewer"));
                    record.setApprover(row.optString("approver"));
                    record.setOverallNote(row.optString("overallNote"));
                    record.setImagePath(row.optString("imagePath"));
                    String createdAt = row.optString("createdAt", null);
                    if (createdAt != null && !createdAt.isBlank()) {
                        record.setCreatedAt(LocalDateTime.parse(createdAt));
                    }

                    List<ChecklistRecord.ItemResult> itemResults = new ArrayList<>();
                    JSONArray checkArray = row.optJSONArray("checks");
                    if (checkArray != null) {
                        for (int j = 0; j < checkArray.length(); j++) {
                            JSONObject check = checkArray.getJSONObject(j);
                            ChecklistRecord.ItemResult result = new ChecklistRecord.ItemResult();
                            result.setItemName(check.optString("itemName"));
                            result.setDone(check.optBoolean("done"));
                            result.setComment(check.optString("comment"));
                            itemResults.add(result);
                        }
                    }
                    record.setResults(itemResults);
                    records.add(record);
                }
            }
        } catch (IOException e) {
            throw new RuntimeException("체크리스트 파일을 읽는 중 오류가 발생했습니다.", e);
        }
    }

    private synchronized void persist() {
        JSONObject root = new JSONObject();
        JSONArray configs = new JSONArray();

        for (Map.Entry<String, List<String>> entry : configMap.entrySet()) {
            for (String item : entry.getValue()) {
                JSONObject cfg = new JSONObject();
                cfg.put("period", entry.getKey());
                cfg.put("item", item);
                configs.put(cfg);
            }
        }

        JSONArray recordArray = new JSONArray();
        for (ChecklistRecord record : records) {
            JSONObject row = new JSONObject();
            row.put("id", record.getId());
            row.put("periodType", record.getPeriodType());
            row.put("title", record.getChecklistTitle());
            row.put("writer", record.getWriter());
            row.put("reviewer", record.getReviewer());
            row.put("approver", record.getApprover());
            row.put("overallNote", record.getOverallNote());
            row.put("imagePath", record.getImagePath());
            row.put("createdAt", record.getCreatedAt() == null ? "" : record.getCreatedAt().toString());

            JSONArray checks = new JSONArray();
            for (ChecklistRecord.ItemResult result : record.getResults()) {
                JSONObject check = new JSONObject();
                check.put("itemName", result.getItemName());
                check.put("done", result.isDone());
                check.put("comment", result.getComment());
                checks.put(check);
            }
            row.put("checks", checks);
            recordArray.put(row);
        }

        root.put("configs", configs);
        root.put("records", recordArray);

        try {
            Files.createDirectories(jsonPath.getParent());
            Files.writeString(jsonPath, root.toString(2), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException("체크리스트 파일 저장 중 오류가 발생했습니다.", e);
        }
    }
}

package com.checklist.model;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class InspectionResult {
    private String id;
    private String templateId;
    private String templateTitle;
    private String checkedAt;
    private String writer;
    private String reviewer;
    private String approver;
    private List<InspectionItemResult> itemResults = new ArrayList<>();

    public JSONObject toJson() {
        JSONObject obj = new JSONObject();
        obj.put("id", id);
        obj.put("templateId", templateId);
        obj.put("templateTitle", templateTitle);
        obj.put("checkedAt", checkedAt);
        obj.put("writer", writer);
        obj.put("reviewer", reviewer);
        obj.put("approver", approver);

        JSONArray array = new JSONArray();
        for (InspectionItemResult item : itemResults) {
            array.put(item.toJson());
        }
        obj.put("itemResults", array);
        return obj;
    }

    public static InspectionResult fromJson(JSONObject obj) {
        InspectionResult result = new InspectionResult();
        result.setId(obj.optString("id"));
        result.setTemplateId(obj.optString("templateId"));
        result.setTemplateTitle(obj.optString("templateTitle"));
        result.setCheckedAt(obj.optString("checkedAt"));
        result.setWriter(obj.optString("writer"));
        result.setReviewer(obj.optString("reviewer"));
        result.setApprover(obj.optString("approver"));

        List<InspectionItemResult> parsedItems = new ArrayList<>();
        JSONArray array = obj.optJSONArray("itemResults");
        if (array != null) {
            for (int i = 0; i < array.length(); i++) {
                parsedItems.add(InspectionItemResult.fromJson(array.getJSONObject(i)));
            }
        }
        result.setItemResults(parsedItems);
        return result;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getTemplateId() { return templateId; }
    public void setTemplateId(String templateId) { this.templateId = templateId; }
    public String getTemplateTitle() { return templateTitle; }
    public void setTemplateTitle(String templateTitle) { this.templateTitle = templateTitle; }
    public String getCheckedAt() { return checkedAt; }
    public void setCheckedAt(String checkedAt) { this.checkedAt = checkedAt; }
    public String getWriter() { return writer; }
    public void setWriter(String writer) { this.writer = writer; }
    public String getReviewer() { return reviewer; }
    public void setReviewer(String reviewer) { this.reviewer = reviewer; }
    public String getApprover() { return approver; }
    public void setApprover(String approver) { this.approver = approver; }
    public List<InspectionItemResult> getItemResults() { return itemResults; }
    public void setItemResults(List<InspectionItemResult> itemResults) { this.itemResults = itemResults; }
}

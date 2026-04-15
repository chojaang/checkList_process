package com.checklist.model;

import org.json.JSONObject;

public class InspectionItemResult {
    private String itemName;
    private String status;
    private String note;
    private String inspectionImagePath;

    public JSONObject toJson() {
        JSONObject obj = new JSONObject();
        obj.put("itemName", itemName);
        obj.put("status", status);
        obj.put("note", note);
        obj.put("inspectionImagePath", inspectionImagePath);
        return obj;
    }

    public static InspectionItemResult fromJson(JSONObject obj) {
        InspectionItemResult result = new InspectionItemResult();
        result.setItemName(obj.optString("itemName"));
        result.setStatus(obj.optString("status"));
        result.setNote(obj.optString("note"));
        result.setInspectionImagePath(obj.optString("inspectionImagePath"));
        return result;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getInspectionImagePath() {
        return inspectionImagePath;
    }

    public void setInspectionImagePath(String inspectionImagePath) {
        this.inspectionImagePath = inspectionImagePath;
    }
}

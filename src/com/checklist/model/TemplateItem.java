package com.checklist.model;

import org.json.JSONObject;

public class TemplateItem {
    private String itemName;
    private String description;
    private String referenceImagePath;

    public JSONObject toJson() {
        JSONObject obj = new JSONObject();
        obj.put("itemName", itemName);
        obj.put("description", description);
        obj.put("referenceImagePath", referenceImagePath);
        return obj;
    }

    public static TemplateItem fromJson(JSONObject obj) {
        TemplateItem item = new TemplateItem();
        item.setItemName(obj.optString("itemName"));
        item.setDescription(obj.optString("description"));
        item.setReferenceImagePath(obj.optString("referenceImagePath"));
        return item;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getReferenceImagePath() {
        return referenceImagePath;
    }

    public void setReferenceImagePath(String referenceImagePath) {
        this.referenceImagePath = referenceImagePath;
    }
}

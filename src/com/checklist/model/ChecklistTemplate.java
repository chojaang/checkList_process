package com.checklist.model;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class ChecklistTemplate {
    private String id;
    private String title;
    private String period;
    private List<TemplateItem> items = new ArrayList<>();

    public JSONObject toJson() {
        JSONObject obj = new JSONObject();
        obj.put("id", id);
        obj.put("title", title);
        obj.put("period", period);

        JSONArray itemsArray = new JSONArray();
        for (TemplateItem item : items) {
            itemsArray.put(item.toJson());
        }
        obj.put("items", itemsArray);
        return obj;
    }

    public static ChecklistTemplate fromJson(JSONObject obj) {
        ChecklistTemplate template = new ChecklistTemplate();
        template.setId(obj.optString("id"));
        template.setTitle(obj.optString("title"));
        template.setPeriod(obj.optString("period"));

        List<TemplateItem> parsedItems = new ArrayList<>();
        JSONArray array = obj.optJSONArray("items");
        if (array != null) {
            for (int i = 0; i < array.length(); i++) {
                parsedItems.add(TemplateItem.fromJson(array.getJSONObject(i)));
            }
        }
        template.setItems(parsedItems);
        return template;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getPeriod() {
        return period;
    }

    public void setPeriod(String period) {
        this.period = period;
    }

    public List<TemplateItem> getItems() {
        return items;
    }

    public void setItems(List<TemplateItem> items) {
        this.items = items;
    }
}

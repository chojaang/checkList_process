package com.checklist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ChecklistRecord {
    public static class ItemResult {
        private String itemName;
        private boolean done;
        private String comment;

        public ItemResult() {
        }

        public ItemResult(String itemName, boolean done, String comment) {
            this.itemName = itemName;
            this.done = done;
            this.comment = comment;
        }

        public String getItemName() {
            return itemName;
        }

        public void setItemName(String itemName) {
            this.itemName = itemName;
        }

        public boolean isDone() {
            return done;
        }

        public void setDone(boolean done) {
            this.done = done;
        }

        public String getComment() {
            return comment;
        }

        public void setComment(String comment) {
            this.comment = comment;
        }
    }

    private String id;
    private String periodType;
    private String checklistTitle;
    private String writer;
    private String reviewer;
    private String approver;
    private String overallNote;
    private String imagePath;
    private LocalDateTime createdAt;
    private List<ItemResult> results = new ArrayList<>();

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPeriodType() {
        return periodType;
    }

    public void setPeriodType(String periodType) {
        this.periodType = periodType;
    }

    public String getChecklistTitle() {
        return checklistTitle;
    }

    public void setChecklistTitle(String checklistTitle) {
        this.checklistTitle = checklistTitle;
    }

    public String getWriter() {
        return writer;
    }

    public void setWriter(String writer) {
        this.writer = writer;
    }

    public String getReviewer() {
        return reviewer;
    }

    public void setReviewer(String reviewer) {
        this.reviewer = reviewer;
    }

    public String getApprover() {
        return approver;
    }

    public void setApprover(String approver) {
        this.approver = approver;
    }

    public String getOverallNote() {
        return overallNote;
    }

    public void setOverallNote(String overallNote) {
        this.overallNote = overallNote;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public List<ItemResult> getResults() {
        return results;
    }

    public void setResults(List<ItemResult> results) {
        this.results = results;
    }
}

package com.visioncare.model;

public class ServiceWorkflowStep {
    private int id;
    private int serviceId;
    private String stepName;
    private String stepStage; // 'PRE_EXAM', 'IN_EXAM', 'POST_EXAM'
    private int stepOrder;
    private String description;

    public ServiceWorkflowStep() {
    }

    public ServiceWorkflowStep(int id, int serviceId, String stepName, String stepStage, int stepOrder, String description) {
        this.id = id;
        this.serviceId = serviceId;
        this.stepName = stepName;
        this.stepStage = stepStage != null ? stepStage : "PRE_EXAM";
        this.stepOrder = stepOrder;
        this.description = description;
    }

    public ServiceWorkflowStep(String stepName, String stepStage, int stepOrder, String description) {
        this(0, 0, stepName, stepStage, stepOrder, description);
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }

    public String getStepName() { return stepName; }
    public void setStepName(String stepName) { this.stepName = stepName; }

    public String getStepStage() { return stepStage; }
    public void setStepStage(String stepStage) { this.stepStage = stepStage; }

    public int getStepOrder() { return stepOrder; }
    public void setStepOrder(int stepOrder) { this.stepOrder = stepOrder; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStageDisplayName() {
        if ("PRE_EXAM".equalsIgnoreCase(stepStage)) return "Trước khám";
        if ("IN_EXAM".equalsIgnoreCase(stepStage)) return "Trong khám";
        if ("POST_EXAM".equalsIgnoreCase(stepStage)) return "Sau khám";
        return "Quy trình";
    }

    public String getStageBadgeClass() {
        if ("PRE_EXAM".equalsIgnoreCase(stepStage)) return "bg-primary-subtle text-primary border border-primary-subtle";
        if ("IN_EXAM".equalsIgnoreCase(stepStage)) return "bg-info-subtle text-info-emphasis border border-info-subtle";
        if ("POST_EXAM".equalsIgnoreCase(stepStage)) return "bg-success-subtle text-success border border-success-subtle";
        return "bg-secondary-subtle text-secondary";
    }

    public String getStageIcon() {
        if ("PRE_EXAM".equalsIgnoreCase(stepStage)) return "bi-clipboard2-pulse";
        if ("IN_EXAM".equalsIgnoreCase(stepStage)) return "bi-person-check";
        if ("POST_EXAM".equalsIgnoreCase(stepStage)) return "bi-check2-circle";
        return "bi-arrow-right-circle";
    }
}

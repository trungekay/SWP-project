package com.visioncare.model;

public class ServiceCategory {
    private final int id;
    private final String name;

    public ServiceCategory(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() { return id; }
    public String getName() { return name; }
}

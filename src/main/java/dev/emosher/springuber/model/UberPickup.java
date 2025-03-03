package dev.emosher.springuber.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity
public class UberPickup {
    @Id
    private Integer hour;
    private Integer count;

    // Getters and setters
    public Integer getHour() { return hour; }
    public void setHour(Integer hour) { this.hour = hour; }
    public Integer getCount() { return count; }
    public void setCount(Integer count) { this.count = count; }
}
package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Promotion {

  private String airingEndDate;

  private String airingStartDate;

  private String title;

  private String description;

  public Promotion() {
  }

  public String getAiringEndDate() {
    return airingEndDate;
  }

  public void setAiringEndDate(String airingEndDate) {
    this.airingEndDate = airingEndDate;
  }

  public String getAiringStartDate() {
    return airingStartDate;
  }

  public void setAiringStartDate(String airingStartDate) {
    this.airingStartDate = airingStartDate;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

}

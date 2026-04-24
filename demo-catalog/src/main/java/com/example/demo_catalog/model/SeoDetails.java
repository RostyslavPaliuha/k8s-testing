package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class SeoDetails {

  private boolean indexedByRobots;

  public SeoDetails() {
  }

  public boolean isIndexedByRobots() {
    return indexedByRobots;
  }

  public void setIndexedByRobots(boolean indexedByRobots) {
    this.indexedByRobots = indexedByRobots;
  }

}

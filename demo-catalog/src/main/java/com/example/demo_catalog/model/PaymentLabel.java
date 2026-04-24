package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class PaymentLabel {

  private String type;

  private Long timeLeft;

  private String productName;

  private boolean viewingPermitted;

  private String productId;

  public PaymentLabel() {
  }

  public String getType() {
    return type;
  }

  public void setType(String type) {
    this.type = type;
  }

  public Long getTimeLeft() {
    return timeLeft;
  }

  public void setTimeLeft(Long timeLeft) {
    this.timeLeft = timeLeft;
  }

  public String getProductName() {
    return productName;
  }

  public void setProductName(String productName) {
    this.productName = productName;
  }

  public boolean isViewingPermitted() {
    return viewingPermitted;
  }

  public void setViewingPermitted(boolean viewingPermitted) {
    this.viewingPermitted = viewingPermitted;
  }

  public String getProductId() {
    return productId;
  }

  public void setProductId(String productId) {
    this.productId = productId;
  }

}

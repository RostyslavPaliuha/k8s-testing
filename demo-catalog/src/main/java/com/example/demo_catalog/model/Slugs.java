package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Slugs {

  private String ru_RU;

  private String en_US;

  private String uk_UA;

  public Slugs() {
  }

  public String getRu_RU() {
    return ru_RU;
  }

  public void setRu_RU(String ru_RU) {
    this.ru_RU = ru_RU;
  }

  public String getEn_US() {
    return en_US;
  }

  public void setEn_US(String en_US) {
    this.en_US = en_US;
  }

  public String getUk_UA() {
    return uk_UA;
  }

  public void setUk_UA(String uk_UA) {
    this.uk_UA = uk_UA;
  }

}

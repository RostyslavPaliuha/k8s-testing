package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class LocalizedSubtitle {

  private String languageCode;

  private String localizedLanguage;

  public LocalizedSubtitle() {
  }

  public LocalizedSubtitle(String languageCode, String localizedLanguage) {
    this.languageCode = languageCode;
    this.localizedLanguage = localizedLanguage;
  }

  public String getLanguageCode() {
    return languageCode;
  }

  public void setLanguageCode(String languageCode) {
    this.languageCode = languageCode;
  }

  public String getLocalizedLanguage() {
    return localizedLanguage;
  }

  public void setLocalizedLanguage(String localizedLanguage) {
    this.localizedLanguage = localizedLanguage;
  }

}

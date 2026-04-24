package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ImgFile {

  private String fileName;

  public ImgFile() {
  }

  public ImgFile(String fileName) {
    this.fileName = fileName;
  }

  public String getFileName() {
    return fileName;
  }

  public void setFileName(String fileName) {
    this.fileName = fileName;
  }

}

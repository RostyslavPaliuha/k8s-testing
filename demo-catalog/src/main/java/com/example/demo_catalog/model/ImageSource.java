package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ImageSource {

  private String url;

  private List<ImgFile> imgFiles;

  public ImageSource() {
  }

  public String getUrl() {
    return url;
  }

  public void setUrl(String url) {
    this.url = url;
  }

  public List<ImgFile> getImgFiles() {
    return imgFiles;
  }

  public void setImgFiles(List<ImgFile> imgFiles) {
    this.imgFiles = imgFiles;
  }

}

package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class CatalogResponse {

  private String name;

  private String type;

  private List<Asset> assets;

  private String assetId;

  private String slug;

  private Slugs slugs;

  private SeoDetails seoDetails;

  private boolean playTrailer;

  private boolean pinProtected;

  private boolean pinValidated;

  public CatalogResponse() {
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getType() {
    return type;
  }

  public void setType(String type) {
    this.type = type;
  }

  public List<Asset> getAssets() {
    return assets;
  }

  public void setAssets(List<Asset> assets) {
    this.assets = assets;
  }

  public String getAssetId() {
    return assetId;
  }

  public void setAssetId(String assetId) {
    this.assetId = assetId;
  }

  public String getSlug() {
    return slug;
  }

  public void setSlug(String slug) {
    this.slug = slug;
  }

  public Slugs getSlugs() {
    return slugs;
  }

  public void setSlugs(Slugs slugs) {
    this.slugs = slugs;
  }

  public SeoDetails getSeoDetails() {
    return seoDetails;
  }

  public void setSeoDetails(SeoDetails seoDetails) {
    this.seoDetails = seoDetails;
  }

  public boolean isPlayTrailer() {
    return playTrailer;
  }

  public void setPlayTrailer(boolean playTrailer) {
    this.playTrailer = playTrailer;
  }

  @JsonProperty("playTrailer")
  public boolean isPlayTrailerJson() {
    return playTrailer;
  }

  public boolean isPinProtected() {
    return pinProtected;
  }

  public void setPinProtected(boolean pinProtected) {
    this.pinProtected = pinProtected;
  }

  @JsonProperty("pinProtected")
  public boolean isPinProtectedJson() {
    return pinProtected;
  }

  public boolean isPinValidated() {
    return pinValidated;
  }

  public void setPinValidated(boolean pinValidated) {
    this.pinValidated = pinValidated;
  }

  @JsonProperty("pinValidated")
  public boolean isPinValidatedJson() {
    return pinValidated;
  }

}

package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Asset {

  private String name;

  private List<ImageSource> imagesSource;

  private Integer releaseDate;

  private List<Genre> genres;

  private List<String> genresList;

  private Integer likeCount;

  private Integer dislikeCount;

  private Integer checkInCount;

  private boolean notRecommended;

  private boolean externalEnabled;

  private boolean protectedAsset;

  private VodMetaData vodMetaData;

  private boolean isPromoAsset;

  private String providerName;

  private String providerExternalId;

  private String shortPlot;

  private boolean isPopularProgramVod;

  private String slug;

  private List<String> subscriberTypes;

  private Integer lastLocation;

  private boolean watched;

  private boolean downloadable;

  private boolean deactivated;

  private ParentalRating parentalRating;

  private boolean onWatchList;

  private boolean pinValidated;

  private Integer duration;

  private Integer introEnd;

  private Integer closingCreditsStart;

  private String audioTrackLanguageCode;

  private boolean isGeoBlocked;

  private boolean purchased;

  private PaymentLabel paymentLabel;

  private List<LocalizedSubtitle> localizedSubtitles;

  private List<String> localizedAudioTracksLanguages;

  private boolean announce;

  private List<Rating> ratings;

  private String assetId;

  private List<String> tags;

  private String assetType;

  private Promotion promotion;

  private String promotionFeaturedType;

  public Asset() {
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public List<ImageSource> getImagesSource() {
    return imagesSource;
  }

  public void setImagesSource(List<ImageSource> imagesSource) {
    this.imagesSource = imagesSource;
  }

  public Integer getReleaseDate() {
    return releaseDate;
  }

  public void setReleaseDate(Integer releaseDate) {
    this.releaseDate = releaseDate;
  }

  public List<Genre> getGenres() {
    return genres;
  }

  public void setGenres(List<Genre> genres) {
    this.genres = genres;
  }

  public List<String> getGenresList() {
    return genresList;
  }

  public void setGenresList(List<String> genresList) {
    this.genresList = genresList;
  }

  public Integer getLikeCount() {
    return likeCount;
  }

  public void setLikeCount(Integer likeCount) {
    this.likeCount = likeCount;
  }

  public Integer getDislikeCount() {
    return dislikeCount;
  }

  public void setDislikeCount(Integer dislikeCount) {
    this.dislikeCount = dislikeCount;
  }

  public Integer getCheckInCount() {
    return checkInCount;
  }

  public void setCheckInCount(Integer checkInCount) {
    this.checkInCount = checkInCount;
  }

  public boolean isNotRecommended() {
    return notRecommended;
  }

  public void setNotRecommended(boolean notRecommended) {
    this.notRecommended = notRecommended;
  }

  @JsonProperty("notRecommended")
  public boolean isNotRecommendedJson() {
    return notRecommended;
  }

  public boolean isExternalEnabled() {
    return externalEnabled;
  }

  public void setExternalEnabled(boolean externalEnabled) {
    this.externalEnabled = externalEnabled;
  }

  @JsonProperty("externalEnabled")
  public boolean isExternalEnabledJson() {
    return externalEnabled;
  }

  public boolean isProtectedAsset() {
    return protectedAsset;
  }

  public void setProtectedAsset(boolean protectedAsset) {
    this.protectedAsset = protectedAsset;
  }

  @JsonProperty("protectedAsset")
  public boolean isProtectedAssetJson() {
    return protectedAsset;
  }

  public VodMetaData getVodMetaData() {
    return vodMetaData;
  }

  public void setVodMetaData(VodMetaData vodMetaData) {
    this.vodMetaData = vodMetaData;
  }

  public boolean isPromoAsset() {
    return isPromoAsset;
  }

  public void setPromoAsset(boolean promoAsset) {
    isPromoAsset = promoAsset;
  }

  @JsonProperty("isPromoAsset")
  public boolean isPromoAssetJson() {
    return isPromoAsset;
  }

  public String getProviderName() {
    return providerName;
  }

  public void setProviderName(String providerName) {
    this.providerName = providerName;
  }

  public String getProviderExternalId() {
    return providerExternalId;
  }

  public void setProviderExternalId(String providerExternalId) {
    this.providerExternalId = providerExternalId;
  }

  public String getShortPlot() {
    return shortPlot;
  }

  public void setShortPlot(String shortPlot) {
    this.shortPlot = shortPlot;
  }

  public boolean isPopularProgramVod() {
    return isPopularProgramVod;
  }

  public void setPopularProgramVod(boolean popularProgramVod) {
    isPopularProgramVod = popularProgramVod;
  }

  @JsonProperty("isPopularProgramVod")
  public boolean isPopularProgramVodJson() {
    return isPopularProgramVod;
  }

  public String getSlug() {
    return slug;
  }

  public void setSlug(String slug) {
    this.slug = slug;
  }

  public List<String> getSubscriberTypes() {
    return subscriberTypes;
  }

  public void setSubscriberTypes(List<String> subscriberTypes) {
    this.subscriberTypes = subscriberTypes;
  }

  public Integer getLastLocation() {
    return lastLocation;
  }

  public void setLastLocation(Integer lastLocation) {
    this.lastLocation = lastLocation;
  }

  public boolean isWatched() {
    return watched;
  }

  public void setWatched(boolean watched) {
    this.watched = watched;
  }

  @JsonProperty("watched")
  public boolean isWatchedJson() {
    return watched;
  }

  public boolean isDownloadable() {
    return downloadable;
  }

  public void setDownloadable(boolean downloadable) {
    this.downloadable = downloadable;
  }

  @JsonProperty("downloadable")
  public boolean isDownloadableJson() {
    return downloadable;
  }

  public boolean isDeactivated() {
    return deactivated;
  }

  public void setDeactivated(boolean deactivated) {
    this.deactivated = deactivated;
  }

  @JsonProperty("deactivated")
  public boolean isDeactivatedJson() {
    return deactivated;
  }

  public ParentalRating getParentalRating() {
    return parentalRating;
  }

  public void setParentalRating(ParentalRating parentalRating) {
    this.parentalRating = parentalRating;
  }

  public boolean isOnWatchList() {
    return onWatchList;
  }

  public void setOnWatchList(boolean onWatchList) {
    this.onWatchList = onWatchList;
  }

  @JsonProperty("onWatchList")
  public boolean isOnWatchListJson() {
    return onWatchList;
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

  public Integer getDuration() {
    return duration;
  }

  public void setDuration(Integer duration) {
    this.duration = duration;
  }

  public Integer getIntroEnd() {
    return introEnd;
  }

  public void setIntroEnd(Integer introEnd) {
    this.introEnd = introEnd;
  }

  public Integer getClosingCreditsStart() {
    return closingCreditsStart;
  }

  public void setClosingCreditsStart(Integer closingCreditsStart) {
    this.closingCreditsStart = closingCreditsStart;
  }

  public String getAudioTrackLanguageCode() {
    return audioTrackLanguageCode;
  }

  public void setAudioTrackLanguageCode(String audioTrackLanguageCode) {
    this.audioTrackLanguageCode = audioTrackLanguageCode;
  }

  public boolean isGeoBlocked() {
    return isGeoBlocked;
  }

  public void setGeoBlocked(boolean geoBlocked) {
    isGeoBlocked = geoBlocked;
  }

  @JsonProperty("isGeoBlocked")
  public boolean isGeoBlockedJson() {
    return isGeoBlocked;
  }

  public boolean isPurchased() {
    return purchased;
  }

  public void setPurchased(boolean purchased) {
    this.purchased = purchased;
  }

  @JsonProperty("purchased")
  public boolean isPurchasedJson() {
    return purchased;
  }

  public PaymentLabel getPaymentLabel() {
    return paymentLabel;
  }

  public void setPaymentLabel(PaymentLabel paymentLabel) {
    this.paymentLabel = paymentLabel;
  }

  public List<LocalizedSubtitle> getLocalizedSubtitles() {
    return localizedSubtitles;
  }

  public void setLocalizedSubtitles(List<LocalizedSubtitle> localizedSubtitles) {
    this.localizedSubtitles = localizedSubtitles;
  }

  public List<String> getLocalizedAudioTracksLanguages() {
    return localizedAudioTracksLanguages;
  }

  public void setLocalizedAudioTracksLanguages(List<String> localizedAudioTracksLanguages) {
    this.localizedAudioTracksLanguages = localizedAudioTracksLanguages;
  }

  public boolean isAnnounce() {
    return announce;
  }

  public void setAnnounce(boolean announce) {
    this.announce = announce;
  }

  @JsonProperty("announce")
  public boolean isAnnounceJson() {
    return announce;
  }

  public List<Rating> getRatings() {
    return ratings;
  }

  public void setRatings(List<Rating> ratings) {
    this.ratings = ratings;
  }

  public String getAssetId() {
    return assetId;
  }

  public void setAssetId(String assetId) {
    this.assetId = assetId;
  }

  public List<String> getTags() {
    return tags;
  }

  public void setTags(List<String> tags) {
    this.tags = tags;
  }

  public String getAssetType() {
    return assetType;
  }

  public void setAssetType(String assetType) {
    this.assetType = assetType;
  }

  public Promotion getPromotion() {
    return promotion;
  }

  public void setPromotion(Promotion promotion) {
    this.promotion = promotion;
  }

  public String getPromotionFeaturedType() {
    return promotionFeaturedType;
  }

  public void setPromotionFeaturedType(String promotionFeaturedType) {
    this.promotionFeaturedType = promotionFeaturedType;
  }

}

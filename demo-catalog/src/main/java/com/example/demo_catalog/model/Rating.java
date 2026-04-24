package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Rating {

  private String movieId;

  private String ratingProviderType;

  private Double movieRating;

  private Long lastUpdateTime;

  private Integer numberOfVotes;

  public Rating() {
  }

  public Rating(String movieId, String ratingProviderType, Double movieRating, Long lastUpdateTime, Integer numberOfVotes) {
    this.movieId = movieId;
    this.ratingProviderType = ratingProviderType;
    this.movieRating = movieRating;
    this.lastUpdateTime = lastUpdateTime;
    this.numberOfVotes = numberOfVotes;
  }

  public String getMovieId() {
    return movieId;
  }

  public void setMovieId(String movieId) {
    this.movieId = movieId;
  }

  public String getRatingProviderType() {
    return ratingProviderType;
  }

  public void setRatingProviderType(String ratingProviderType) {
    this.ratingProviderType = ratingProviderType;
  }

  public Double getMovieRating() {
    return movieRating;
  }

  public void setMovieRating(Double movieRating) {
    this.movieRating = movieRating;
  }

  public Long getLastUpdateTime() {
    return lastUpdateTime;
  }

  public void setLastUpdateTime(Long lastUpdateTime) {
    this.lastUpdateTime = lastUpdateTime;
  }

  public Integer getNumberOfVotes() {
    return numberOfVotes;
  }

  public void setNumberOfVotes(Integer numberOfVotes) {
    this.numberOfVotes = numberOfVotes;
  }

}

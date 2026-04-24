package com.example.demo_catalog.model;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class VodMetaData {

  private Map<String, String> audioTracks;

  public VodMetaData() {
  }

  public Map<String, String> getAudioTracks() {
    return audioTracks;
  }

  public void setAudioTracks(Map<String, String> audioTracks) {
    this.audioTracks = audioTracks;
  }

}

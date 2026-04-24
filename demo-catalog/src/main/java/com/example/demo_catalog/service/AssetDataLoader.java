package com.example.demo_catalog.service;

import com.example.demo_catalog.model.Asset;
import com.example.demo_catalog.model.Genre;
import com.example.demo_catalog.model.ImageSource;
import com.example.demo_catalog.model.ImgFile;
import com.example.demo_catalog.model.LocalizedSubtitle;
import com.example.demo_catalog.model.ParentalRating;
import com.example.demo_catalog.model.PaymentLabel;
import com.example.demo_catalog.model.Promotion;
import com.example.demo_catalog.model.Rating;
import com.example.demo_catalog.model.VodMetaData;
import jakarta.annotation.PostConstruct;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

@Service
public class AssetDataLoader {

  private static final String ASSETS_FIELD = "assets";

  private static final TypeReference<Map<String, String>> AUDIO_TRACKS_TYPE = new TypeReference<>() {};

  private final ObjectMapper objectMapper;

  private JsonNode assetsJsonNode;

  public AssetDataLoader(ObjectMapper objectMapper) {
    this.objectMapper = objectMapper;
  }

  @PostConstruct
  public void init() throws IOException {
    ClassPathResource resource = new ClassPathResource("assets.json");
    try (InputStream inputStream = resource.getInputStream()) {
      assetsJsonNode = objectMapper.readTree(inputStream);
    }
  }

  public List<Asset> loadAssets() {
    return loadAssets(assetsJsonNode);
  }

  private Asset mapToAsset(JsonNode node) {
    Asset asset = new Asset();
    asset.setName(text(node, "name"));
    asset.setAssetId(text(node, "assetId"));
    asset.setReleaseDate(integer(node, "releaseDate"));
    asset.setGenres(mapGenres(field(node, "genres")));
    asset.setGenresList(mapStringList(field(node, "genresList")));
    asset.setLikeCount(integer(node, "likeCount"));
    asset.setDislikeCount(integer(node, "dislikeCount"));
    asset.setCheckInCount(integer(node, "checkInCount"));
    asset.setNotRecommended(bool(node, "notRecommended"));
    asset.setExternalEnabled(bool(node, "externalEnabled"));
    asset.setProtectedAsset(bool(node, "protectedAsset"));
    asset.setVodMetaData(mapVodMetaData(field(node, "vodMetaData")));
    asset.setPromoAsset(bool(node, "isPromoAsset"));
    asset.setProviderName(text(node, "providerName"));
    asset.setProviderExternalId(text(node, "providerExternalId"));
    asset.setShortPlot(text(node, "shortPlot"));
    asset.setPopularProgramVod(bool(node, "isPopularProgramVod"));
    asset.setSlug(text(node, "slug"));
    asset.setSubscriberTypes(mapStringList(field(node, "subscriberTypes")));
    asset.setLastLocation(integer(node, "lastLocation"));
    asset.setWatched(bool(node, "watched"));
    asset.setDownloadable(bool(node, "downloadable"));
    asset.setDeactivated(bool(node, "deactivated"));
    asset.setParentalRating(mapParentalRating(field(node, "parentalRating")));
    asset.setOnWatchList(bool(node, "onWatchList"));
    asset.setPinValidated(bool(node, "pinValidated"));
    asset.setDuration(integer(node, "duration"));
    asset.setIntroEnd(integer(node, "introEnd"));
    asset.setClosingCreditsStart(integer(node, "closingCreditsStart"));
    asset.setAudioTrackLanguageCode(text(node, "audioTrackLanguageCode"));
    asset.setGeoBlocked(bool(node, "isGeoBlocked"));
    asset.setPurchased(bool(node, "purchased"));
    asset.setPaymentLabel(mapPaymentLabel(field(node, "paymentLabel")));
    asset.setLocalizedSubtitles(mapLocalizedSubtitles(field(node, "localizedSubtitles")));
    asset.setLocalizedAudioTracksLanguages(mapStringList(field(node, "localizedAudioTracksLanguages")));
    asset.setAnnounce(bool(node, "announce"));
    asset.setRatings(mapRatings(field(node, "ratings")));
    asset.setTags(mapStringList(field(node, "tags")));
    asset.setAssetType(text(node, "assetType"));
    asset.setImagesSource(mapImageSources(field(node, "imagesSource")));
    asset.setPromotion(mapPromotion(field(node, "promotion")));
    asset.setPromotionFeaturedType(text(node, "promotionFeaturedType"));
    return asset;
  }

  private List<Genre> mapGenres(JsonNode node) {
    return mapArrayOrNull(node, genreNode -> {
      Genre genre = new Genre();
      genre.setValue(text(genreNode, "value"));
      genre.setLocale(text(genreNode, "locale"));
      return genre;
    });
  }

  private List<String> mapStringList(JsonNode node) {
    return mapArrayOrNull(node, item -> item.isTextual() ? item.asText() : null);
  }

  private VodMetaData mapVodMetaData(JsonNode node) {
    if (node == null) {
      return null;
    }
    VodMetaData vodMetaData = new VodMetaData();
    JsonNode audioTracksNode = field(node, "audioTracks");
    if (audioTracksNode != null && audioTracksNode.isObject()) {
      vodMetaData.setAudioTracks(objectMapper.convertValue(audioTracksNode, AUDIO_TRACKS_TYPE));
    }
    return vodMetaData;
  }

  private ParentalRating mapParentalRating(JsonNode node) {
    if (node == null) {
      return null;
    }
    ParentalRating parentalRating = new ParentalRating();
    parentalRating.setValue(text(node, "value"));
    parentalRating.setType(text(node, "type"));
    return parentalRating;
  }

  private PaymentLabel mapPaymentLabel(JsonNode node) {
    if (node == null) {
      return null;
    }
    PaymentLabel paymentLabel = new PaymentLabel();
    paymentLabel.setType(text(node, "type"));
    paymentLabel.setProductName(text(node, "productName"));
    paymentLabel.setProductId(text(node, "productId"));
    paymentLabel.setTimeLeft(longValue(node, "timeLeft"));
    paymentLabel.setViewingPermitted(bool(node, "viewingPermitted"));
    return paymentLabel;
  }

  private List<LocalizedSubtitle> mapLocalizedSubtitles(JsonNode node) {
    return mapArrayOrNull(node, subtitleNode -> {
      LocalizedSubtitle subtitle = new LocalizedSubtitle();
      subtitle.setLanguageCode(text(subtitleNode, "languageCode"));
      subtitle.setLocalizedLanguage(text(subtitleNode, "localizedLanguage"));
      return subtitle;
    });
  }

  private List<Rating> mapRatings(JsonNode node) {
    return mapArrayOrNull(node, ratingNode -> {
      Rating rating = new Rating();
      rating.setMovieId(text(ratingNode, "movieId"));
      rating.setRatingProviderType(text(ratingNode, "ratingProviderType"));
      rating.setMovieRating(doubleValue(ratingNode, "movieRating"));
      rating.setLastUpdateTime(longValue(ratingNode, "lastUpdateTime"));
      rating.setNumberOfVotes(integer(ratingNode, "numberOfVotes"));
      return rating;
    });
  }

  private List<ImageSource> mapImageSources(JsonNode node) {
    return mapArrayOrNull(node, imageSourceNode -> {
      ImageSource imageSource = new ImageSource();
      imageSource.setUrl(text(imageSourceNode, "url"));
      imageSource.setImgFiles(mapImgFiles(field(imageSourceNode, "imgFiles")));
      return imageSource;
    });
  }

  private List<ImgFile> mapImgFiles(JsonNode node) {
    return mapArrayOrNull(node, imgFileNode -> {
      ImgFile imgFile = new ImgFile();
      imgFile.setFileName(text(imgFileNode, "fileName"));
      return imgFile;
    });
  }

  private Promotion mapPromotion(JsonNode node) {
    if (node == null) {
      return null;
    }
    Promotion promotion = new Promotion();
    promotion.setAiringEndDate(text(node, "airingEndDate"));
    promotion.setAiringStartDate(text(node, "airingStartDate"));
    promotion.setTitle(text(node, "title"));
    promotion.setDescription(text(node, "description"));
    return promotion;
  }

  private <T> List<T> mapArrayOrNull(JsonNode node, Function<JsonNode, T> mapper) {
    return mapArray(node, mapper, null);
  }

  private <T> List<T> mapArray(JsonNode node, Function<JsonNode, T> mapper, List<T> defaultValue) {
    if (node == null || !node.isArray()) {
      return defaultValue;
    }
    List<T> values = new ArrayList<>();
    for (JsonNode item : node) {
      T value = mapper.apply(item);
      if (value != null) {
        values.add(value);
      }
    }
    return values;
  }

  private JsonNode field(JsonNode node, String field) {
    if (node == null || !node.has(field)) {
      return null;
    }
    return node.get(field);
  }

  private String text(JsonNode node, String field) {
    JsonNode fieldNode = field(node, field);
    return fieldNode != null && fieldNode.isTextual() ? fieldNode.asText() : null;
  }

  private Integer integer(JsonNode node, String field) {
    JsonNode fieldNode = field(node, field);
    return fieldNode != null && fieldNode.isInt() ? fieldNode.asInt() : null;
  }

  private Long longValue(JsonNode node, String field) {
    JsonNode fieldNode = field(node, field);
    return fieldNode != null && (fieldNode.isLong() || fieldNode.isInt()) ? fieldNode.asLong()
                                                                          : null;
  }

  private Double doubleValue(JsonNode node, String field) {
    JsonNode fieldNode = field(node, field);
    return fieldNode != null && (fieldNode.isDouble() || fieldNode.isFloat() || fieldNode.isInt())
           ? fieldNode.asDouble() : null;
  }

  private boolean bool(JsonNode node, String field) {
    JsonNode fieldNode = field(node, field);
    return fieldNode != null && fieldNode.isBoolean() && fieldNode.asBoolean();
  }

  List<Asset> loadAssets(JsonNode rootNode) {
    return mapArray(field(rootNode, ASSETS_FIELD), this::mapToAsset, new ArrayList<>());
  }

}

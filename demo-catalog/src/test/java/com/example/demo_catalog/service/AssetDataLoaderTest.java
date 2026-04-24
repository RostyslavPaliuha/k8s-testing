package com.example.demo_catalog.service;

import com.example.demo_catalog.model.Asset;
import org.junit.jupiter.api.Test;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class AssetDataLoaderTest {

  private final ObjectMapper objectMapper = new ObjectMapper();
  private final AssetDataLoader loader = new AssetDataLoader(objectMapper);

  @Test
  void loadAssetsMapsAssetFieldsAndNestedObjects() throws Exception {
    JsonNode rootNode = objectMapper.readTree("""
        {
          "assets": [
            {
              "name": "Life",
              "assetId": "asset-1",
              "releaseDate": 2017,
              "genres": [
                {
                  "value": "SCIFI",
                  "locale": "Science fiction"
                }
              ],
              "genresList": ["Science fiction", "Thriller"],
              "likeCount": 175,
              "dislikeCount": 17,
              "checkInCount": 2,
              "notRecommended": true,
              "externalEnabled": true,
              "protectedAsset": true,
              "vodMetaData": {
                "audioTracks": {
                  "uk": "track-url"
                }
              },
              "isPromoAsset": true,
              "providerName": "OVVA",
              "providerExternalId": "provider-1",
              "shortPlot": "Plot",
              "isPopularProgramVod": true,
              "slug": "life-2017",
              "subscriberTypes": ["ADULT"],
              "lastLocation": 42,
              "watched": true,
              "downloadable": true,
              "deactivated": true,
              "parentalRating": {
                "value": "16",
                "type": "MCRF"
              },
              "onWatchList": true,
              "pinValidated": true,
              "duration": 6238,
              "introEnd": 66,
              "closingCreditsStart": 5675,
              "audioTrackLanguageCode": "uk",
              "isGeoBlocked": true,
              "purchased": true,
              "paymentLabel": {
                "type": "PURCHASED_SVOD",
                "timeLeft": 3147402502697,
                "productName": "Premium",
                "viewingPermitted": true,
                "productId": "product-1"
              },
              "localizedSubtitles": [
                {
                  "languageCode": "ukr",
                  "localizedLanguage": "Ukrainian"
                }
              ],
              "localizedAudioTracksLanguages": ["ukr"],
              "announce": true,
              "ratings": [
                {
                  "movieId": "movie-1",
                  "ratingProviderType": "IMDB",
                  "movieRating": 6.6,
                  "lastUpdateTime": 1710000000000,
                  "numberOfVotes": 100
                }
              ],
              "tags": ["space"],
              "assetType": "VOD",
              "imagesSource": [
                {
                  "url": "image-url",
                  "imgFiles": [
                    {
                      "fileName": "IMAGE_16_9_XL.jpg"
                    }
                  ]
                }
              ],
              "promotion": {
                "airingEndDate": "2026-01-01",
                "airingStartDate": "2025-01-01",
                "title": "Featured",
                "description": "Promotion description"
              },
              "promotionFeaturedType": "HERO"
            }
          ]
        }
        """);

    List<Asset> assets = loader.loadAssets(rootNode);

    assertThat(assets).hasSize(1);
    Asset asset = assets.getFirst();
    assertThat(asset.getName()).isEqualTo("Life");
    assertThat(asset.getAssetId()).isEqualTo("asset-1");
    assertThat(asset.getReleaseDate()).isEqualTo(2017);
    assertThat(asset.getGenres()).singleElement().satisfies(genre -> {
      assertThat(genre.getValue()).isEqualTo("SCIFI");
      assertThat(genre.getLocale()).isEqualTo("Science fiction");
    });
    assertThat(asset.getGenresList()).containsExactly("Science fiction", "Thriller");
    assertThat(asset.getLikeCount()).isEqualTo(175);
    assertThat(asset.getDislikeCount()).isEqualTo(17);
    assertThat(asset.getCheckInCount()).isEqualTo(2);
    assertThat(asset.isNotRecommended()).isTrue();
    assertThat(asset.isExternalEnabled()).isTrue();
    assertThat(asset.isProtectedAsset()).isTrue();
    assertThat(asset.getVodMetaData().getAudioTracks()).containsEntry("uk", "track-url");
    assertThat(asset.isPromoAsset()).isTrue();
    assertThat(asset.getProviderName()).isEqualTo("OVVA");
    assertThat(asset.getProviderExternalId()).isEqualTo("provider-1");
    assertThat(asset.getShortPlot()).isEqualTo("Plot");
    assertThat(asset.isPopularProgramVod()).isTrue();
    assertThat(asset.getSlug()).isEqualTo("life-2017");
    assertThat(asset.getSubscriberTypes()).containsExactly("ADULT");
    assertThat(asset.getLastLocation()).isEqualTo(42);
    assertThat(asset.isWatched()).isTrue();
    assertThat(asset.isDownloadable()).isTrue();
    assertThat(asset.isDeactivated()).isTrue();
    assertThat(asset.getParentalRating().getValue()).isEqualTo("16");
    assertThat(asset.getParentalRating().getType()).isEqualTo("MCRF");
    assertThat(asset.isOnWatchList()).isTrue();
    assertThat(asset.isPinValidated()).isTrue();
    assertThat(asset.getDuration()).isEqualTo(6238);
    assertThat(asset.getIntroEnd()).isEqualTo(66);
    assertThat(asset.getClosingCreditsStart()).isEqualTo(5675);
    assertThat(asset.getAudioTrackLanguageCode()).isEqualTo("uk");
    assertThat(asset.isGeoBlocked()).isTrue();
    assertThat(asset.isPurchased()).isTrue();
    assertThat(asset.getPaymentLabel().getType()).isEqualTo("PURCHASED_SVOD");
    assertThat(asset.getPaymentLabel().getTimeLeft()).isEqualTo(3147402502697L);
    assertThat(asset.getPaymentLabel().getProductName()).isEqualTo("Premium");
    assertThat(asset.getPaymentLabel().isViewingPermitted()).isTrue();
    assertThat(asset.getPaymentLabel().getProductId()).isEqualTo("product-1");
    assertThat(asset.getLocalizedSubtitles()).singleElement().satisfies(subtitle -> {
      assertThat(subtitle.getLanguageCode()).isEqualTo("ukr");
      assertThat(subtitle.getLocalizedLanguage()).isEqualTo("Ukrainian");
    });
    assertThat(asset.getLocalizedAudioTracksLanguages()).containsExactly("ukr");
    assertThat(asset.isAnnounce()).isTrue();
    assertThat(asset.getRatings()).singleElement().satisfies(rating -> {
      assertThat(rating.getMovieId()).isEqualTo("movie-1");
      assertThat(rating.getRatingProviderType()).isEqualTo("IMDB");
      assertThat(rating.getMovieRating()).isEqualTo(6.6);
      assertThat(rating.getLastUpdateTime()).isEqualTo(1710000000000L);
      assertThat(rating.getNumberOfVotes()).isEqualTo(100);
    });
    assertThat(asset.getTags()).containsExactly("space");
    assertThat(asset.getAssetType()).isEqualTo("VOD");
    assertThat(asset.getImagesSource()).singleElement().satisfies(imageSource -> {
      assertThat(imageSource.getUrl()).isEqualTo("image-url");
      assertThat(imageSource.getImgFiles()).singleElement()
          .satisfies(imgFile -> assertThat(imgFile.getFileName()).isEqualTo("IMAGE_16_9_XL.jpg"));
    });
    assertThat(asset.getPromotion().getAiringEndDate()).isEqualTo("2026-01-01");
    assertThat(asset.getPromotion().getAiringStartDate()).isEqualTo("2025-01-01");
    assertThat(asset.getPromotion().getTitle()).isEqualTo("Featured");
    assertThat(asset.getPromotion().getDescription()).isEqualTo("Promotion description");
    assertThat(asset.getPromotionFeaturedType()).isEqualTo("HERO");
  }

  @Test
  void loadAssetsReturnsEmptyListWhenAssetsFieldIsMissingOrNotAnArray() throws Exception {
    assertThat(loader.loadAssets(objectMapper.readTree("{}"))).isEmpty();
    assertThat(loader.loadAssets(objectMapper.readTree("{\"assets\": {}}"))).isEmpty();
  }

  @Test
  void loadAssetsKeepsExistingDefaultsForInvalidOptionalValues() throws Exception {
    JsonNode rootNode = objectMapper.readTree("""
        {
          "assets": [
            {
              "name": 123,
              "releaseDate": "2017",
              "genresList": ["Drama", 5, true],
              "notRecommended": "true",
              "paymentLabel": {
                "viewingPermitted": "true"
              },
              "ratings": [
                {
                  "movieRating": "6.6"
                }
              ]
            }
          ]
        }
        """);

    Asset asset = loader.loadAssets(rootNode).getFirst();

    assertThat(asset.getName()).isNull();
    assertThat(asset.getReleaseDate()).isNull();
    assertThat(asset.getGenresList()).containsExactly("Drama");
    assertThat(asset.isNotRecommended()).isFalse();
    assertThat(asset.getPaymentLabel().isViewingPermitted()).isFalse();
    assertThat(asset.getRatings()).singleElement()
        .satisfies(rating -> assertThat(rating.getMovieRating()).isNull());
  }
}

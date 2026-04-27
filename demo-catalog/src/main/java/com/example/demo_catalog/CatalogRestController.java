package com.example.demo_catalog;

import com.example.demo_catalog.model.CatalogResponse;
import com.example.demo_catalog.model.SeoDetails;
import com.example.demo_catalog.model.Slugs;
import com.example.demo_catalog.service.AssetDataLoader;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.ThreadLocalRandom;

@RestController
@RequestMapping("/api/v1/")
public class CatalogRestController {

  private final AssetDataLoader assetDataLoader;

  public CatalogRestController(AssetDataLoader assetDataLoader) {
    this.assetDataLoader = assetDataLoader;
  }

  @GetMapping("/assets")
  public CatalogResponse catalog() {
    CatalogResponse response = new CatalogResponse();
    response.setName("Саме час подивитись");
    response.setType("REGULAR");
    response.setAssetId("66ed660bdb741d2d9edb6038");
    response.setSlug("66ed660bdb741d2d9edb6038-same-chas-podivitis");
    Slugs slugs = new Slugs();
    slugs.setRu_RU("66ed660bdb741d2d9edb6038-samoe-vremya-posmotret");
    slugs.setEn_US("66ed660bdb741d2d9edb6038-its-time-to-watch");
    slugs.setUk_UA("66ed660bdb741d2d9edb6038-same-chas-podivitis");
    response.setSlugs(slugs);
    SeoDetails seoDetails = new SeoDetails();
    seoDetails.setIndexedByRobots(true);
    response.setSeoDetails(seoDetails);
    response.setPlayTrailer(false);
    response.setPinProtected(false);
    response.setPinValidated(false);
    response.setAssets(assetDataLoader.loadAssets());
    return response;
  }

  private void makeARandomDelay() {
    ThreadLocalRandom random = ThreadLocalRandom.current();
    int randomDelay = random.ints(100, 500).findFirst().orElseGet(() -> 100);
    try {
      Thread.sleep(randomDelay);
    } catch (InterruptedException e) {
      throw new RuntimeException(e);
    }
  }

}

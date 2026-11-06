enum AdsProvider { google, facebook, none }

class AdsConfig {
  // Toggle between AdMob, Facebook, or None
  static AdsProvider currentProvider = AdsProvider.google;

  // GOOGLE ADMOB IDs (Test IDs)
  static const String googleAndroidBannerId = "ca-app-pub-3940256099942544/6300978111";
  static const String googleAndroidInterstitialId = "ca-app-pub-3940256099942544/1033173712";
  static const String googleIOSBannerId = "ca-app-pub-3940256099942544/2934735716";
  static const String googleIOSInterstitialId = "ca-app-pub-3940256099942544/4411468910";

  // FACEBOOK AUDIENCE NETWORK IDs (Test IDs - REPLACE WITH REAL ONES)
  static const String facebookAndroidBannerId = "YOUR_FB_ANDROID_BANNER_PLACEMENT_ID";
  static const String facebookAndroidInterstitialId = "YOUR_FB_ANDROID_INTERSTITIAL_PLACEMENT_ID";
  static const String facebookIOSBannerId = "YOUR_FB_IOS_BANNER_PLACEMENT_ID";
  static const String facebookIOSInterstitialId = "YOUR_FB_IOS_INTERSTITIAL_PLACEMENT_ID";

  // Frequency Control
  static const int interstitialInterval = 3; // Show every 3 major actions
}

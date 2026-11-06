import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import '../config/ads_config.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  InterstitialAd? _googleInterstitialAd;
  bool _isFBInterstitialLoaded = false;
  int _actionCounter = 0;

  static Future<void> init() async {
    if (AdsConfig.currentProvider == AdsProvider.google) {
      await MobileAds.instance.initialize();
    } else if (AdsConfig.currentProvider == AdsProvider.facebook) {
      await FacebookAudienceNetwork.init();
    }
  }

  // --- INTERSTITIAL ADS ---

  void loadInterstitialAd() {
    if (AdsConfig.currentProvider == AdsProvider.google) {
      _loadGoogleInterstitial();
    } else if (AdsConfig.currentProvider == AdsProvider.facebook) {
      _loadFacebookInterstitial();
    }
  }

  void _loadGoogleInterstitial() {
    final adId = Platform.isAndroid ? AdsConfig.googleAndroidInterstitialId : AdsConfig.googleIOSInterstitialId;
    InterstitialAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _googleInterstitialAd = ad;
          _googleInterstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadGoogleInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadGoogleInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _googleInterstitialAd = null;
        },
      ),
    );
  }

  void _loadFacebookInterstitial() {
    final adId = Platform.isAndroid ? AdsConfig.facebookAndroidInterstitialId : AdsConfig.facebookIOSInterstitialId;
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: adId,
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED) {
          _isFBInterstitialLoaded = true;
        } else if (result == InterstitialAdResult.DISMISSED || result == InterstitialAdResult.ERROR) {
          _isFBInterstitialLoaded = false;
          _loadFacebookInterstitial();
        }
      },
    );
  }

  void showInterstitialIfReady() {
    _actionCounter++;
    if (_actionCounter % AdsConfig.interstitialInterval != 0) return;

    if (AdsConfig.currentProvider == AdsProvider.google && _googleInterstitialAd != null) {
      _googleInterstitialAd!.show();
    } else if (AdsConfig.currentProvider == AdsProvider.facebook && _isFBInterstitialLoaded) {
      FacebookInterstitialAd.showInterstitialAd();
    }
  }

  // --- BANNER ADS WIDGET ---

  Widget getBannerAd() {
    if (AdsConfig.currentProvider == AdsProvider.google) {
      return const GoogleBannerAdWidget();
    } else if (AdsConfig.currentProvider == AdsProvider.facebook) {
      return const FacebookBannerAdWidget();
    }
    return const SizedBox.shrink();
  }
}

// --- HELPER WIDGETS ---

class GoogleBannerAdWidget extends StatefulWidget {
  const GoogleBannerAdWidget({super.key});

  @override
  State<GoogleBannerAdWidget> createState() => _GoogleBannerAdWidgetState();
}

class _GoogleBannerAdWidgetState extends State<GoogleBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final adId = Platform.isAndroid ? AdsConfig.googleAndroidBannerId : AdsConfig.googleIOSBannerId;
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adId,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

class FacebookBannerAdWidget extends StatelessWidget {
  const FacebookBannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final adId = Platform.isAndroid ? AdsConfig.facebookAndroidBannerId : AdsConfig.facebookIOSBannerId;
    return FacebookBannerAd(
      placementId: adId,
      bannerSize: BannerSize.STANDARD,
      listener: (result, value) {},
    );
  }
}

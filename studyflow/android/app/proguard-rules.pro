# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in C:\flutter\packages\flutter_tools\gradle\flutter_proguard_rules.pro
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Facebook Audience Network
-dontwarn com.facebook.infer.annotation.**
-keep class com.facebook.ads.** { *; }

# Google Play Core
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# AdMob
-keep public class com.google.android.gms.ads.** {
   public *;
}

# General Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

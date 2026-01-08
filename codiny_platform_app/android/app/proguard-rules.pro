# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep model classes for JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep HTTP client classes
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Provider
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class androidx.lifecycle.** { *; }

# Prevent obfuscation of model classes
-keep class ma.codiny.drivingexam.data.models.** { *; }

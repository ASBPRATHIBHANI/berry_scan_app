# TensorFlow Lite rules
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLite (sqflite) specific rules
-keep class com.tekartik.sqflite.** { *; }
-keep class com.tekartik.sqflite.SqflitePlugin { *; }

# Prevent general native method stripping
-keepclasseswithmembernames class * {
    native <methods>;
}
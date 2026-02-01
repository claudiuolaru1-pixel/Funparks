# Keep Flutter, Firebase, and Google Maps essentials
-keep class io.flutter.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
# Keep JSON models (reflective access)
-keep class **.models.** { *; }

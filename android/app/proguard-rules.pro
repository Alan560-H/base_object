# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep MainActivity and MethodChannel usage
-keep class com.ruyimh.MainActivity { *; }

# Anythink / 优量汇 GDT（按需补充 keep，若崩溃再加）
-keep class com.anythink.** { *; }
-dontwarn com.anythink.**
-keep class com.qq.e.** { *; }
-dontwarn com.qq.e.**

# 保留 native 方法
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保留序列化
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

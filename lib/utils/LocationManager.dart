import 'package:geolocator/geolocator.dart';

class LocationManager {
  // 初始化定位服务
  static Future<bool> initializeLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return false;
      }
    }

    return true;
  }

  // 获取当前位置
  static Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // 高精度定位
        timeLimit: Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  // 检查位置是否在指定区域内
  static bool isWithinArea(
    Position location,
    Position center,
    double radiusMeters,
  ) {
    double distanceInMeters = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      center.latitude,
      center.longitude,
    );
    return distanceInMeters <= radiusMeters;
  }
}

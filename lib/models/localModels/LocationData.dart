/// 位置信息
final class LocationData {
  final String? address;
  final double? latitude;
  final double? longitude;

  LocationData({this.address, this.latitude, this.longitude});

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    address: json['address'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };
}

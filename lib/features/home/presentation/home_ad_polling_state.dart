import 'package:flutter/foundation.dart';

@immutable
class HomeAdPollingState {
  const HomeAdPollingState({
    this.bannerIntervalSeconds = 8,
    this.nativeIntervalSeconds = 15,
    this.bannerPollingEnabled = false,
    this.nativePollingEnabled = false,
  });

  static const int minIntervalSeconds = 3;
  static const int maxIntervalSeconds = 120;

  final int bannerIntervalSeconds;
  final int nativeIntervalSeconds;
  final bool bannerPollingEnabled;
  final bool nativePollingEnabled;

  HomeAdPollingState copyWith({
    int? bannerIntervalSeconds,
    int? nativeIntervalSeconds,
    bool? bannerPollingEnabled,
    bool? nativePollingEnabled,
  }) {
    return HomeAdPollingState(
      bannerIntervalSeconds: bannerIntervalSeconds ?? this.bannerIntervalSeconds,
      nativeIntervalSeconds: nativeIntervalSeconds ?? this.nativeIntervalSeconds,
      bannerPollingEnabled: bannerPollingEnabled ?? this.bannerPollingEnabled,
      nativePollingEnabled: nativePollingEnabled ?? this.nativePollingEnabled,
    );
  }

  static int clampInterval(int seconds) {
    return seconds.clamp(minIntervalSeconds, maxIntervalSeconds);
  }
}

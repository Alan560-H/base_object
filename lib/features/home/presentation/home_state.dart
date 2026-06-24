import 'package:flutter/foundation.dart';

@immutable
class HomeState {
  const HomeState({
    this.currentIp = '获取中...',
    this.appDisplayName = '',
    this.ipRefreshedAt = '',
    this.ipRefreshing = false,
  });

  final String currentIp;
  final String appDisplayName;
  final String ipRefreshedAt;
  final bool ipRefreshing;

  HomeState copyWith({
    String? currentIp,
    String? appDisplayName,
    String? ipRefreshedAt,
    bool? ipRefreshing,
  }) {
    return HomeState(
      currentIp: currentIp ?? this.currentIp,
      appDisplayName: appDisplayName ?? this.appDisplayName,
      ipRefreshedAt: ipRefreshedAt ?? this.ipRefreshedAt,
      ipRefreshing: ipRefreshing ?? this.ipRefreshing,
    );
  }
}

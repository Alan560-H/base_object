import 'package:base_object/features/home/presentation/home_ad_polling_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeAdPollingNotifier extends Notifier<HomeAdPollingState> {
  @override
  HomeAdPollingState build() => const HomeAdPollingState();

  void incrementBannerInterval() {
    state = state.copyWith(
      bannerIntervalSeconds: HomeAdPollingState.clampInterval(
        state.bannerIntervalSeconds + 1,
      ),
    );
  }

  void decrementBannerInterval() {
    state = state.copyWith(
      bannerIntervalSeconds: HomeAdPollingState.clampInterval(
        state.bannerIntervalSeconds - 1,
      ),
    );
  }

  void incrementNativeInterval() {
    state = state.copyWith(
      nativeIntervalSeconds: HomeAdPollingState.clampInterval(
        state.nativeIntervalSeconds + 1,
      ),
    );
  }

  void decrementNativeInterval() {
    state = state.copyWith(
      nativeIntervalSeconds: HomeAdPollingState.clampInterval(
        state.nativeIntervalSeconds - 1,
      ),
    );
  }

  void setBannerPollingEnabled(bool enabled) {
    if (state.bannerPollingEnabled == enabled) return;
    state = state.copyWith(bannerPollingEnabled: enabled);
  }

  void setNativePollingEnabled(bool enabled) {
    if (state.nativePollingEnabled == enabled) return;
    state = state.copyWith(nativePollingEnabled: enabled);
  }

  void setBannerIntervalSeconds(int seconds) {
    final int clamped = HomeAdPollingState.clampInterval(seconds);
    if (state.bannerIntervalSeconds == clamped) return;
    state = state.copyWith(bannerIntervalSeconds: clamped);
  }

  void setNativeIntervalSeconds(int seconds) {
    final int clamped = HomeAdPollingState.clampInterval(seconds);
    if (state.nativeIntervalSeconds == clamped) return;
    state = state.copyWith(nativeIntervalSeconds: clamped);
  }
}

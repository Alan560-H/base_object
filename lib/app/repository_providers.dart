import 'package:base_object/data/repositories/ad_stats_repository.dart';
import 'package:base_object/data/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adStatsRepositoryProvider = Provider<AdStatsRepository>(
  (ref) => AdStatsRepository(),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

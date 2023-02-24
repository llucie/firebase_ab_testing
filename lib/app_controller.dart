import 'package:firebase_ab_testing/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RemoteConfigKeys {
  donationFirstAmount,
  donationSecondAmount,
  donationThirdAmount,
}

final retrieveFromRemoteConfig = FutureProvider<List<int>>((ref) async {
  final remoteConfig = ref.watch(remoteConfigProvider);

  final firstAmount = remoteConfig.getInt(RemoteConfigKeys.donationFirstAmount.name);
  final secondAmount = remoteConfig.getInt(RemoteConfigKeys.donationSecondAmount.name);
  final thirdAmount = remoteConfig.getInt(RemoteConfigKeys.donationThirdAmount.name);

  debugPrint('FIRST = $firstAmount');

  return [firstAmount, secondAmount, thirdAmount];
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/alert.dart';
import '../repositories/alert_repository.dart';

final alertRepositoryProvider = Provider((ref) {
  return AlertRepository(ref.read(apiClientProvider));
});

final alertListProvider = FutureProvider.autoDispose<List<AlertItem>>((ref) {
  return ref.read(alertRepositoryProvider).list();
});

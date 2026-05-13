import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/wastage.dart';
import '../repositories/wastage_repository.dart';

final wastageRepositoryProvider = Provider((ref) {
  return WastageRepository(ref.read(apiClientProvider));
});

final wastageListProvider =
    FutureProvider.autoDispose<List<WastageRecord>>((ref) {
  return ref.read(wastageRepositoryProvider).list();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/stock_movement.dart';
import '../repositories/stock_movement_repository.dart';

final stockMovementRepositoryProvider = Provider((ref) {
  return StockMovementRepository(ref.read(apiClientProvider));
});

final stockMovementListProvider =
    FutureProvider.autoDispose<List<StockMovement>>((ref) {
  return ref.read(stockMovementRepositoryProvider).list();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/sale.dart';
import '../repositories/sale_repository.dart';

final saleRepositoryProvider = Provider((ref) {
  return SaleRepository(ref.read(apiClientProvider));
});

final saleListProvider = FutureProvider.autoDispose<List<SaleEntry>>((ref) {
  return ref.read(saleRepositoryProvider).list();
});

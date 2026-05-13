import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/bill.dart';
import '../repositories/bill_repository.dart';

final billRepositoryProvider = Provider((ref) {
  return BillRepository(ref.read(apiClientProvider));
});

final billListProvider = FutureProvider.autoDispose<List<VendorBill>>((ref) {
  return ref.read(billRepositoryProvider).list();
});

final billDetailProvider =
    FutureProvider.autoDispose.family<VendorBill, String>((ref, id) {
  return ref.read(billRepositoryProvider).getById(id);
});

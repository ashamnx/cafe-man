import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/vendor.dart';
import '../repositories/vendor_repository.dart';

final vendorRepositoryProvider = Provider((ref) {
  return VendorRepository(ref.read(apiClientProvider));
});

final vendorListProvider =
    FutureProvider.autoDispose.family<List<Vendor>, String>((ref, search) {
  return ref.read(vendorRepositoryProvider).list(search: search);
});

final vendorDetailProvider =
    FutureProvider.autoDispose.family<Vendor, String>((ref, id) {
  return ref.read(vendorRepositoryProvider).getById(id);
});

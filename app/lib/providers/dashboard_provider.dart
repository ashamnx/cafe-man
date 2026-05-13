import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/dashboard.dart';
import '../repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) {
  return ref.read(dashboardRepositoryProvider).getDashboard();
});

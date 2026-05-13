import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/audit_log_entry.dart';
import '../repositories/audit_repository.dart';

final auditRepositoryProvider = Provider((ref) {
  return AuditRepository(ref.read(apiClientProvider));
});

class AuditFilter {
  final String? entityType;
  final String? action;
  final int page;

  const AuditFilter({this.entityType, this.action, this.page = 1});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditFilter &&
          runtimeType == other.runtimeType &&
          entityType == other.entityType &&
          action == other.action &&
          page == other.page;

  @override
  int get hashCode => Object.hash(entityType, action, page);
}

final auditLogProvider =
    FutureProvider.autoDispose.family<AuditLogResponse, AuditFilter>(
        (ref, filter) {
  return ref.read(auditRepositoryProvider).list(
        entityType: filter.entityType,
        action: filter.action,
        page: filter.page,
      );
});

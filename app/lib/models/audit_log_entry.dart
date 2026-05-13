class AuditLogEntry {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String entityType;
  final String entityId;
  final String ipAddress;
  final DateTime createdAt;

  AuditLogEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.ipAddress,
    required this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      action: json['action'] ?? '',
      entityType: json['entity_type'] ?? '',
      entityId: json['entity_id'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class AuditLogResponse {
  final List<AuditLogEntry> entries;
  final int total;
  final int page;
  final int totalPages;

  AuditLogResponse({
    required this.entries,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory AuditLogResponse.fromJson(Map<String, dynamic> json) {
    return AuditLogResponse(
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => AuditLogEntry.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class Role {
  final String id;
  final String name;
  final String description;
  final bool isSystem;
  final List<Permission> permissions;

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.isSystem,
    required this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isSystem: json['is_system'] ?? false,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => Permission.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Permission {
  final String id;
  final String resource;
  final String action;
  final String description;

  Permission({
    required this.id,
    required this.resource,
    required this.action,
    required this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] ?? '',
      resource: json['resource'] ?? '',
      action: json['action'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

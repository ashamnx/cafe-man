class OrgMember {
  final String userId;
  final String email;
  final String fullName;
  final bool isActive;
  final bool isOwner;
  final List<String> roles;
  final String joinedAt;

  OrgMember({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.isActive,
    required this.isOwner,
    required this.roles,
    required this.joinedAt,
  });

  factory OrgMember.fromJson(Map<String, dynamic> json) {
    return OrgMember(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      isActive: json['is_active'] ?? true,
      isOwner: json['is_owner'] ?? false,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      joinedAt: json['joined_at'] ?? '',
    );
  }
}

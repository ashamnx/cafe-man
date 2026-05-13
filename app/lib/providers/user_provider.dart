import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/org_member.dart';
import '../models/role.dart';
import '../repositories/user_repository.dart';

final userRepositoryProvider = Provider((ref) {
  return UserRepository(ref.read(apiClientProvider));
});

final memberListProvider =
    FutureProvider.autoDispose<List<OrgMember>>((ref) {
  return ref.read(userRepositoryProvider).listMembers();
});

final roleListProvider = FutureProvider.autoDispose<List<Role>>((ref) {
  return ref.read(userRepositoryProvider).listRoles();
});

final roleDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) {
  return ref.read(userRepositoryProvider).getRoleDetail(id);
});

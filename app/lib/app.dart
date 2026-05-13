import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_theme.dart';
import 'features/alerts/screens/alert_list_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/org_selection_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/bills/screens/bill_detail_screen.dart';
import 'features/bills/screens/bill_list_screen.dart';
import 'features/bills/screens/bill_manual_entry_screen.dart';
import 'features/bills/screens/bill_upload_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/ingredients/screens/ingredient_detail_screen.dart';
import 'features/ingredients/screens/ingredient_form_screen.dart';
import 'features/ingredients/screens/ingredient_list_screen.dart';
import 'features/more_screen.dart';
import 'features/recipes/screens/recipe_detail_screen.dart';
import 'features/recipes/screens/recipe_form_screen.dart';
import 'features/recipes/screens/recipe_list_screen.dart';
import 'features/sales/screens/sale_list_screen.dart';
import 'features/stock_movements/screens/stock_movements_screen.dart';
import 'features/vendors/screens/vendor_detail_screen.dart';
import 'features/vendors/screens/vendor_form_screen.dart';
import 'features/vendors/screens/vendor_list_screen.dart';
import 'features/settings/screens/audit_log_screen.dart';
import 'features/settings/screens/invite_user_screen.dart';
import 'features/settings/screens/member_list_screen.dart';
import 'features/settings/screens/role_detail_screen.dart';
import 'features/settings/screens/role_list_screen.dart';
import 'features/wastage/screens/wastage_form_screen.dart';
import 'features/wastage/screens/wastage_list_screen.dart';
import 'providers/auth_provider.dart';
import 'shared/widgets/app_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthRoute =
          state.uri.path == '/login' || state.uri.path == '/register';
      final isSelectOrg = state.uri.path == '/select-org';

      if (authState is AuthUnauthenticated || authState is AuthInitial) {
        return isAuthRoute ? null : '/login';
      }

      if (authState is AuthLoading) {
        return null;
      }

      if (authState is AuthAuthenticated) {
        if (authState.needsOrgSelection) {
          return isSelectOrg ? null : '/select-org';
        }
        if (isAuthRoute || isSelectOrg) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: '/select-org',
          builder: (_, __) => const OrgSelectionScreen()),

      // Main app shell with bottom nav.
      ShellRoute(
        builder: (_, __, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
              path: '/dashboard',
              builder: (_, __) => const DashboardScreen()),
          GoRoute(
              path: '/ingredients',
              builder: (_, __) => const IngredientListScreen()),
          GoRoute(
              path: '/bills',
              builder: (_, __) => const BillListScreen()),
          GoRoute(
              path: '/recipes',
              builder: (_, __) => const RecipeListScreen()),
          GoRoute(
              path: '/more', builder: (_, __) => const MoreScreen()),
          GoRoute(
              path: '/vendors',
              builder: (_, __) => const VendorListScreen()),
          GoRoute(
              path: '/sales',
              builder: (_, __) => const SaleListScreen()),
          GoRoute(
              path: '/wastage',
              builder: (_, __) => const WastageListScreen()),
          GoRoute(
              path: '/stock-movements',
              builder: (_, __) => const StockMovementsScreen()),
          GoRoute(
              path: '/alerts',
              builder: (_, __) => const AlertListScreen()),
        ],
      ),

      // Detail / form routes — outside ShellRoute so they get a full screen
      // with proper back navigation (no bottom nav bar).
      // NOTE: literal paths (/new, /upload) must come before /:id params.
      GoRoute(
        path: '/ingredients/new',
        builder: (_, __) => const IngredientFormScreen(),
      ),
      GoRoute(
        path: '/ingredients/:id/edit',
        builder: (_, state) =>
            IngredientFormScreen(ingredientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ingredients/:id',
        builder: (_, state) =>
            IngredientDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/bills/upload',
        builder: (_, __) => const BillUploadScreen(),
      ),
      GoRoute(
        path: '/bills/manual',
        builder: (_, __) => const BillManualEntryScreen(),
      ),
      GoRoute(
        path: '/bills/:id',
        builder: (_, state) =>
            BillDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/recipes/new',
        builder: (_, __) => const RecipeFormScreen(),
      ),
      GoRoute(
        path: '/recipes/:id/edit',
        builder: (_, state) =>
            RecipeFormScreen(recipeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/recipes/:id',
        builder: (_, state) =>
            RecipeDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/vendors/new',
        builder: (_, __) => const VendorFormScreen(),
      ),
      GoRoute(
        path: '/vendors/:id',
        builder: (_, state) =>
            VendorDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/vendors/:id/edit',
        builder: (_, state) =>
            VendorFormScreen(vendorId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/sales/new',
        builder: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('Record Sale')),
          body: const Center(child: Text('Sale form - Coming Soon')),
        ),
      ),
      GoRoute(
        path: '/sales/:id',
        builder: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('Sale Detail')),
          body: const Center(child: Text('Sale detail - Coming Soon')),
        ),
      ),
      GoRoute(
        path: '/wastage/new',
        builder: (_, __) => const WastageFormScreen(),
      ),

      // Settings routes.
      GoRoute(
        path: '/settings/users',
        builder: (_, __) => const MemberListScreen(),
      ),
      GoRoute(
        path: '/settings/users/invite',
        builder: (_, __) => const InviteUserScreen(),
      ),
      GoRoute(
        path: '/settings/roles',
        builder: (_, __) => const RoleListScreen(),
      ),
      GoRoute(
        path: '/settings/roles/:id',
        builder: (_, state) =>
            RoleDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings/audit-log',
        builder: (_, __) => const AuditLogScreen(),
      ),
    ],
  );
});

class SearloCafeApp extends ConsumerWidget {
  const SearloCafeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Searlo Cafe',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

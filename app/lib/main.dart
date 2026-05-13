import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  container.read(authProvider.notifier).checkAuth();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SearloCafeApp(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/local_storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env").catchError((_) {});

  // Initialize Local Storage
  final localStorageService = HiveLocalStorageService();
  await localStorageService.init();

  // Initialize Supabase
  try {
    await SupabaseService.init();
  } catch (e) {
    debugPrint('Supabase init skipped: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorageService),
      ],
      child: const BentaraApp(),
    ),
  );
}

class BentaraApp extends ConsumerWidget {
  const BentaraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'BENTARA',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

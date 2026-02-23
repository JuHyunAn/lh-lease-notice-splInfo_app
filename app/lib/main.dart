import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경변수 로드
  await dotenv.load(fileName: '.env');

  // Supabase 초기화
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // 카카오맵 SDK 초기화
  AuthRepository.initialize(appKey: dotenv.env['KAKAO_APP_KEY'] ?? '');

  runApp(
    const ProviderScope(
      child: LhLeaseApp(),
    ),
  );
}

/// 앱 루트 위젯
class LhLeaseApp extends StatelessWidget {
  const LhLeaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LH 청약정보',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ko', 'KR'),
    );
  }
}

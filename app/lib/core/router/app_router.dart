import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/notice/notice_detail_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';

/// 앱 라우터 설정
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 메인 Shell (하단 탭 네비게이션)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // 홈 탭 (공고 리스트)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // 지도 탭
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        // 검색 탭
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        // 즐겨찾기 탭
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
      ],
    ),
    // 공고 상세 (탭 외부)
    GoRoute(
      path: '/notice/:noticeId',
      builder: (context, state) {
        final noticeId = state.pathParameters['noticeId']!;
        final noticeName = state.uri.queryParameters['name'] ?? '';
        return NoticeDetailScreen(
          noticeId: noticeId,
          noticeName: noticeName,
        );
      },
    ),
  ],
);

/// 메인 쉘 위젯 (하단 탭 네비게이션 포함)
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: '지도',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: '검색',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: '즐겨찾기',
          ),
        ],
      ),
    );
  }
}

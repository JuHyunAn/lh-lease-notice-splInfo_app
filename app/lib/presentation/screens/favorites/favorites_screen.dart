import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 즐겨찾기 화면 (기능 5 - Phase 4에서 완성)
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              '즐겨찾기한 공고가 없습니다',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 8),
            Text(
              '공고 상세에서 즐겨찾기를 추가해보세요',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

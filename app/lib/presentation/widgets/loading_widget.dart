import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

/// 공고 카드 스켈레톤 로딩
class NoticeCardSkeleton extends StatelessWidget {
  const NoticeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFFE5E9F0),
          highlightColor: const Color(0xFFF5F7FA),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ShimmerBox(width: 60, height: 22, radius: 6),
                  const SizedBox(width: 8),
                  _ShimmerBox(width: 40, height: 22, radius: 6),
                ],
              ),
              const SizedBox(height: 10),
              _ShimmerBox(width: double.infinity, height: 18, radius: 4),
              const SizedBox(height: 6),
              _ShimmerBox(width: 200, height: 18, radius: 4),
              const SizedBox(height: 8),
              _ShimmerBox(width: 120, height: 14, radius: 4),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE5E9F0)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ShimmerBox(width: 80, height: 14, radius: 4),
                  const SizedBox(width: 16),
                  _ShimmerBox(width: 100, height: 14, radius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// 에러 위젯
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/notice_provider.dart';
import '../../widgets/notice_card.dart';
import '../../widgets/loading_widget.dart' as app_widgets;

/// 홈 화면 - 공고 리스트 (기능 1)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  String? _selectedRegion;
  String? _selectedType;

  static const List<String> _regions = [
    '전체', '서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산',
    '세종', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
  ];

  static const List<String> _types = ['전체', '분양', '임대', '토지', '상가'];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noticeAsync = ref.watch(noticeListProvider);
    final urgentAsync = ref.watch(urgentNoticesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  'LH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 알림 설정 (Phase 4)
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(noticeListProvider);
          ref.invalidate(urgentNoticesProvider);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 마감임박 공고 섹션
            SliverToBoxAdapter(
              child: urgentAsync.when(
                data: (urgentList) {
                  if (urgentList.isEmpty) return const SizedBox.shrink();
                  return _UrgentSection(notices: urgentList);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            // 필터 바
            SliverToBoxAdapter(child: _buildFilterBar()),

            // 공고 리스트
            noticeAsync.when(
              data: (notices) {
                if (notices.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 56, color: AppColors.textHint),
                            SizedBox(height: 16),
                            Text(
                              '공고가 없습니다',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => NoticeCard(notice: notices[index]),
                    childCount: notices.length,
                  ),
                );
              },
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, _) => const app_widgets.NoticeCardSkeleton(),
                  childCount: 5,
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: app_widgets.ErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(noticeListProvider),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // 지역 필터
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _regions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final region = _regions[index];
                final isSelected =
                    (index == 0 && _selectedRegion == null) ||
                    region == _selectedRegion;
                return _FilterChip(
                  label: region,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedRegion = index == 0 ? null : region;
                    });
                    ref.read(noticeListFilterProvider.notifier).update(
                      (s) => s.copyWith(region: _selectedRegion),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // 공급 유형 필터
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _types.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final type = _types[index];
                final isSelected =
                    (index == 0 && _selectedType == null) ||
                    type == _selectedType;
                return _FilterChip(
                  label: type,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedType = index == 0 ? null : type;
                    });
                    ref.read(noticeListFilterProvider.notifier).update(
                      (s) => s.copyWith(noticeType: _selectedType),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 마감임박 섹션 (홈 상단 가로 스크롤)
class _UrgentSection extends StatelessWidget {
  final List notices;
  const _UrgentSection({required this.notices});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm, size: 16, color: AppColors.urgentBadge),
              const SizedBox(width: 6),
              Text(
                '마감임박',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.urgentBadge,
                ),
              ),
              const SizedBox(width: 4),
              Text('7일 이내', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: notices.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _UrgentCard(notice: notices[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgentCard extends StatelessWidget {
  final dynamic notice;
  const _UrgentCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.urgentBadge.withAlpha(13),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.urgentBadge.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notice.noticeName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '${notice.region} ${notice.city}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (notice.daysUntilClose != null)
                Text(
                  'D-${notice.daysUntilClose}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.urgentBadge,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 필터 칩
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/notice_provider.dart';
import '../../widgets/notice_card.dart';
import '../../widgets/loading_widget.dart' as app_widgets;

/// 검색 화면 (기능 10)
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    setState(() => _hasSearched = true);
    ref.read(noticeListFilterProvider.notifier).update(
      (s) => s.copyWith(keyword: keyword.trim(), page: 0),
    );
  }

  void _onClear() {
    _searchController.clear();
    setState(() => _hasSearched = false);
    ref.read(noticeListFilterProvider.notifier).update(
      (s) => s.copyWith(keyword: null, page: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noticeAsync = ref.watch(noticeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('검색')),
      body: Column(
        children: [
          // 검색창
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: '공고명, 지역으로 검색',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: _onClear,
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // 키워드 필터 칩 (기능 10)
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              children: _KeywordTag.tags.map((tag) {
                return ActionChip(
                  label: Text(tag.label),
                  avatar: Text(tag.emoji),
                  onPressed: () {
                    _searchController.text = tag.keyword;
                    _onSearch(tag.keyword);
                  },
                  backgroundColor: AppColors.surfaceVariant,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // 검색 결과
          Expanded(
            child: _hasSearched
                ? noticeAsync.when(
                    data: (notices) {
                      if (notices.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 56, color: AppColors.textHint),
                              SizedBox(height: 16),
                              Text(
                                '검색 결과가 없습니다',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: notices.length,
                        itemBuilder: (context, index) =>
                            NoticeCard(notice: notices[index]),
                      );
                    },
                    loading: () => ListView.builder(
                      itemCount: 5,
                      itemBuilder: (_, _) => const app_widgets.NoticeCardSkeleton(),
                    ),
                    error: (error, _) => app_widgets.AppErrorWidget(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(noticeListProvider),
                    ),
                  )
                : const _SearchGuide(),
          ),
        ],
      ),
    );
  }
}

/// 검색 가이드 (검색 전 기본 화면)
class _SearchGuide extends StatelessWidget {
  const _SearchGuide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            '공고를 검색해보세요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '키워드, 지역명으로 빠르게 찾을 수 있어요',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

/// 추천 키워드 태그
class _KeywordTag {
  final String label;
  final String keyword;
  final String emoji;

  const _KeywordTag({
    required this.label,
    required this.keyword,
    required this.emoji,
  });

  static const List<_KeywordTag> tags = [
    _KeywordTag(label: '청년', keyword: '청년', emoji: '👤'),
    _KeywordTag(label: '신혼부부', keyword: '신혼', emoji: '💑'),
    _KeywordTag(label: '생애최초', keyword: '생애최초', emoji: '🏠'),
    _KeywordTag(label: '다자녀', keyword: '다자녀', emoji: '👨‍👩‍👧‍👦'),
    _KeywordTag(label: '행복주택', keyword: '행복주택', emoji: '😊'),
    _KeywordTag(label: '임대', keyword: '임대', emoji: '🔑'),
  ];
}

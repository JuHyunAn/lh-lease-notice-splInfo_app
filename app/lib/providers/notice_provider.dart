import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/notice_model.dart';
import '../data/repositories/notice_repository.dart';

/// Supabase 클라이언트 Provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// 공고 레포지토리 Provider
final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return NoticeRepository(client);
});

/// 지도용 공고 목록 필터 상태
class NoticeMapFilter {
  final String? region;
  final String? noticeType;

  const NoticeMapFilter({this.region, this.noticeType});

  // sentinel: null을 '값 없음'과 '초기화'로 구분
  static const _unset = Object();

  NoticeMapFilter copyWith({
    Object? region = _unset,
    Object? noticeType = _unset,
  }) {
    return NoticeMapFilter(
      region: identical(region, _unset) ? this.region : region as String?,
      noticeType: identical(noticeType, _unset) ? this.noticeType : noticeType as String?,
    );
  }
}

/// 지도 필터 상태 Provider
final noticeMapFilterProvider =
    StateProvider<NoticeMapFilter>((ref) => const NoticeMapFilter());

/// 지도용 공고 목록 Provider
final noticeMapProvider =
    FutureProvider.autoDispose<List<NoticeMapModel>>((ref) async {
  final repo = ref.watch(noticeRepositoryProvider);
  final filter = ref.watch(noticeMapFilterProvider);
  return repo.getNoticesForMap(
    region: filter.region,
    noticeType: filter.noticeType,
  );
});

/// 공고 리스트 검색어/필터 상태
class NoticeListFilter {
  final String? keyword;
  final String? region;
  final String? noticeType;
  final int page;

  const NoticeListFilter({
    this.keyword,
    this.region,
    this.noticeType,
    this.page = 0,
  });

  // sentinel: null을 '값 없음'과 '초기화'로 구분
  static const _unset = Object();

  NoticeListFilter copyWith({
    Object? keyword = _unset,
    Object? region = _unset,
    Object? noticeType = _unset,
    int? page,
  }) {
    return NoticeListFilter(
      keyword: identical(keyword, _unset) ? this.keyword : keyword as String?,
      region: identical(region, _unset) ? this.region : region as String?,
      noticeType: identical(noticeType, _unset) ? this.noticeType : noticeType as String?,
      page: page ?? this.page,
    );
  }
}

/// 리스트 필터 Provider
final noticeListFilterProvider =
    StateProvider<NoticeListFilter>((ref) => const NoticeListFilter());

/// 공고 리스트 Provider
final noticeListProvider =
    FutureProvider.autoDispose<List<NoticeMapModel>>((ref) async {
  final repo = ref.watch(noticeRepositoryProvider);
  final filter = ref.watch(noticeListFilterProvider);
  return repo.getNoticeList(
    page: filter.page,
    region: filter.region,
    noticeType: filter.noticeType,
    keyword: filter.keyword,
  );
});

/// 공고 상세 Provider
final noticeDetailProvider = FutureProvider.autoDispose
    .family<List<NoticeDetailModel>, String>((ref, noticeId) async {
  final repo = ref.watch(noticeRepositoryProvider);
  return repo.getNoticeDetail(noticeId);
});

/// 마감임박 공고 Provider
final urgentNoticesProvider =
    FutureProvider.autoDispose<List<NoticeMapModel>>((ref) async {
  final repo = ref.watch(noticeRepositoryProvider);
  return repo.getUrgentNotices();
});

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notice_model.dart';
import '../../core/constants/app_constants.dart';

/// 공고 데이터 접근 레포지토리
class NoticeRepository {
  final SupabaseClient _client;
  final Logger _logger = Logger();

  NoticeRepository(this._client);

  /// 지도용 공고 목록 조회 (mart_notice_map)
  Future<List<NoticeMapModel>> getNoticesForMap({
    String? region,
    String? noticeType,
    int? maxDaysUntilClose,
  }) async {
    try {
      var query = _client
          .from(AppConstants.tableNoticeMap)
          .select()
          .not('latitude', 'is', null)
          .not('longitude', 'is', null);

      // 지역 필터
      if (region != null && region.isNotEmpty) {
        query = query.eq('region', region);
      }

      // 공급 유형 필터
      if (noticeType != null && noticeType.isNotEmpty) {
        query = query.ilike('notice_type', '%$noticeType%');
      }

      final response = await query.order('close_date', ascending: true);

      return (response as List)
          .map((json) => NoticeMapModel.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('지도용 공고 조회 실패', error: e);
      rethrow;
    }
  }

  /// 공고 리스트 조회 (페이지네이션)
  Future<List<NoticeMapModel>> getNoticeList({
    int page = 0,
    String? region,
    String? noticeType,
    String? keyword,
  }) async {
    try {
      var query = _client
          .from(AppConstants.tableNoticeMap)
          .select();

      // 키워드 검색
      if (keyword != null && keyword.isNotEmpty) {
        query = query.ilike('notice_name', '%$keyword%');
      }

      // 지역 필터
      if (region != null && region.isNotEmpty) {
        query = query.eq('region', region);
      }

      // 공급 유형 필터
      if (noticeType != null && noticeType.isNotEmpty) {
        query = query.ilike('notice_type', '%$noticeType%');
      }

      final response = await query
          .order('close_date', ascending: true)
          .range(
            page * AppConstants.pageSize,
            (page + 1) * AppConstants.pageSize - 1,
          );

      return (response as List)
          .map((json) => NoticeMapModel.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('공고 리스트 조회 실패', error: e);
      rethrow;
    }
  }

  /// 공고 상세 조회 (mart_notice_detail)
  Future<List<NoticeDetailModel>> getNoticeDetail(String noticeId) async {
    try {
      final response = await _client
          .from(AppConstants.tableNoticeDetail)
          .select()
          .eq('notice_id', noticeId)
          .order('supply_type');

      return (response as List)
          .map((json) => NoticeDetailModel.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('공고 상세 조회 실패 (noticeId: $noticeId)', error: e);
      rethrow;
    }
  }

  /// 마감임박 공고 조회 (7일 이내)
  Future<List<NoticeMapModel>> getUrgentNotices() async {
    try {
      final now = DateTime.now();
      final deadline = now.add(
        const Duration(days: AppConstants.urgentDays),
      );

      final response = await _client
          .from(AppConstants.tableNoticeMap)
          .select()
          .gte('close_date', now.toIso8601String().substring(0, 10))
          .lte('close_date', deadline.toIso8601String().substring(0, 10))
          .order('close_date', ascending: true)
          .limit(10);

      return (response as List)
          .map((json) => NoticeMapModel.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('마감임박 공고 조회 실패', error: e);
      rethrow;
    }
  }
}

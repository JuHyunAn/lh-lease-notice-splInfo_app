import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/notice_provider.dart';
import '../../../data/models/notice_model.dart';

/// 지도 화면 - 카카오맵 + 공고 마커 (기능 2, 6, 10)
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // ignore: unused_field
  KakaoMapController? _mapController;
  NoticeMapModel? _selectedNotice;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final noticeAsync = ref.watch(noticeMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('지도'),
        actions: [
          // 필터 버튼
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 카카오맵
          noticeAsync.when(
            data: (notices) {
              return KakaoMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  _addMarkers(notices);
                },
                onMarkerTap: (markerId, latLng, zoomLevel) {
                  final notice = notices.firstWhere(
                    (n) => n.noticeId == markerId,
                    orElse: () => notices.first,
                  );
                  setState(() => _selectedNotice = notice);
                },
                markers: _markers.toList(),
                center: LatLng(
                  AppConstants.defaultLat,
                  AppConstants.defaultLng,
                ),
                currentLevel: AppConstants.defaultZoom,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 56, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('지도를 불러올 수 없습니다\n$error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(noticeMapProvider),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),

          // 선택된 공고 팝업 (하단)
          if (_selectedNotice != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _NoticePopup(
                notice: _selectedNotice!,
                onClose: () => setState(() => _selectedNotice = null),
                onDetailTap: () {
                  context.push(
                    '/notice/${_selectedNotice!.noticeId}',
                    extra: {'name': _selectedNotice!.noticeName},
                  );
                },
              ),
            ),

          // 공고 수 표시 (좌상단)
          noticeAsync.when(
            data: (notices) => Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '공고 ${notices.length}건',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 마커 추가
  void _addMarkers(List<NoticeMapModel> notices) {
    final markers = <Marker>{};
    for (final notice in notices) {
      if (notice.latitude == null || notice.longitude == null) continue;

      markers.add(
        Marker(
          markerId: notice.noticeId,
          latLng: LatLng(notice.latitude!, notice.longitude!),
          markerImageSrc: _getMarkerImage(notice.typeCode),
        ),
      );
    }
    setState(() => _markers = markers);
  }

  /// 공급 유형별 마커 이미지
  String _getMarkerImage(String typeCode) {
    // 기본 마커 사용 (추후 커스텀 마커 이미지로 교체 가능)
    return '';
  }

  /// 필터 바텀시트
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _MapFilterSheet(),
    );
  }
}

/// 공고 팝업 카드 (지도 마커 터치 시)
class _NoticePopup extends StatelessWidget {
  final NoticeMapModel notice;
  final VoidCallback onClose;
  final VoidCallback onDetailTap;

  const _NoticePopup({
    required this.notice,
    required this.onClose,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Row(
            children: [
              // 유형 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  notice.noticeType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 공고명
          Text(
            notice.noticeName,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // 위치
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${notice.region} ${notice.city}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (notice.closeDate != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${notice.closeDate} 마감',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // 상세보기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDetailTap,
              child: const Text('상세보기'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 지도 필터 바텀시트
class _MapFilterSheet extends ConsumerWidget {
  const _MapFilterSheet();

  static const List<String> _regions = [
    '전체', '서울', '경기', '인천', '부산', '대구',
    '광주', '대전', '울산', '강원', '충북', '충남',
    '전북', '전남', '경북', '경남', '제주',
  ];

  static const List<Map<String, String>> _types = [
    {'code': '', 'label': '전체'},
    {'code': '분양', 'label': '분양'},
    {'code': '임대', 'label': '임대'},
    {'code': '토지', 'label': '토지'},
    {'code': '상가', 'label': '상가'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(noticeMapFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('지역', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _regions.map((region) {
              final isSelected = (region == '전체' && filter.region == null) ||
                  region == filter.region;
              return GestureDetector(
                onTap: () {
                  ref.read(noticeMapFilterProvider.notifier).update(
                    (s) => s.copyWith(region: region == '전체' ? null : region),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    region,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('공급 유형', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _types.map((type) {
              final isSelected = (type['code']!.isEmpty && filter.noticeType == null) ||
                  type['code'] == filter.noticeType;
              return GestureDetector(
                onTap: () {
                  ref.read(noticeMapFilterProvider.notifier).update(
                    (s) => s.copyWith(
                      noticeType: type['code']!.isEmpty ? null : type['code'],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('적용'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/notice_model.dart';

/// 공고 카드 위젯 (리스트/홈 화면용)
class NoticeCard extends StatelessWidget {
  final NoticeMapModel notice;

  const NoticeCard({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(
            '/notice/${notice.noticeId}',
            extra: {'name': notice.noticeName},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 유형 배지 + 뱃지
              Row(
                children: [
                  _TypeBadge(typeCode: notice.typeCode, label: notice.noticeType),
                  const SizedBox(width: 8),
                  if (notice.isNew) _StatusBadge(
                    label: 'NEW',
                    color: AppColors.newBadge,
                  ),
                  if (notice.isUrgent) _StatusBadge(
                    label: '마감임박',
                    color: AppColors.urgentBadge,
                  ),
                  const Spacer(),
                  // 즐겨찾기 버튼
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      // TODO: 즐겨찾기 기능 (Phase 4)
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 공고명
              Text(
                notice.noticeName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 지역
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${notice.region} ${notice.city}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE5E9F0)),
              const SizedBox(height: 12),
              // 하단: 공급 세대수 + 마감일
              Row(
                children: [
                  if (notice.totalSupplyCount != null) ...[
                    const Icon(
                      Icons.apartment_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${notice.totalSupplyCount!.toString()}세대',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (notice.closeDate != null) ...[
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(notice.closeDate!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (notice.daysUntilClose != null) ...[
                      const SizedBox(width: 6),
                      _DdayChip(days: notice.daysUntilClose!),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} 마감';
    } catch (_) {
      return dateStr;
    }
  }
}

/// 공급 유형 배지
class _TypeBadge extends StatelessWidget {
  final String typeCode;
  final String label;

  const _TypeBadge({required this.typeCode, required this.label});

  Color get _color {
    switch (typeCode) {
      case 'HOUSING': return AppColors.typeHousing;
      case 'LAND': return AppColors.typeLand;
      case 'RENTAL': return AppColors.typeRental;
      case 'STORE': return AppColors.typeStore;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withAlpha(77)),
      ),
      child: Text(
        label.length > 6 ? label.substring(0, 6) : label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

/// 상태 배지 (NEW, 마감임박)
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// D-Day 칩
class _DdayChip extends StatelessWidget {
  final int days;

  const _DdayChip({required this.days});

  @override
  Widget build(BuildContext context) {
    final String label = days == 0
        ? 'D-Day'
        : days > 0 ? 'D-$days' : '마감';
    final Color color = days <= 3
        ? AppColors.urgentBadge
        : days <= 7 ? AppColors.warning : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

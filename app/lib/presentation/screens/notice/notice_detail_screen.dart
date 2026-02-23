import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/notice_provider.dart';
import '../../../data/models/notice_model.dart';
import '../../widgets/loading_widget.dart' as app_widgets;

/// 공고 상세 화면 (기능 1, 8)
class NoticeDetailScreen extends ConsumerWidget {
  final String noticeId;
  final String noticeName;

  const NoticeDetailScreen({
    super.key,
    required this.noticeId,
    required this.noticeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(noticeDetailProvider(noticeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          noticeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // 즐겨찾기 버튼
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              // TODO: 즐겨찾기 추가 (Phase 4)
            },
          ),
          // 공유 버튼
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: 공유 기능 (Phase 3)
            },
          ),
        ],
      ),
      body: detailAsync.when(
        data: (details) {
          if (details.isEmpty) {
            return const Center(child: Text('공고 정보를 찾을 수 없습니다.'));
          }
          return _DetailBody(details: details);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => app_widgets.ErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(noticeDetailProvider(noticeId)),
        ),
      ),
    );
  }
}

/// 상세 본문
class _DetailBody extends StatelessWidget {
  final List<NoticeDetailModel> details;

  const _DetailBody({required this.details});

  NoticeDetailModel get _main => details.first;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 카드
          _HeaderCard(notice: _main),
          const SizedBox(height: 16),

          // 공급 정보 섹션
          _SectionTitle(title: '공급 정보 (${details.length}건)'),
          const SizedBox(height: 8),
          ...details.map((d) => _SupplyCard(detail: d)),
          const SizedBox(height: 16),

          // 일정 정보
          _SectionTitle(title: '신청 일정'),
          const SizedBox(height: 8),
          _InfoCard(
            items: [
              _InfoItem(label: '공고 시작일', value: _main.startDate ?? '-'),
              _InfoItem(label: '접수 마감일', value: _main.closeDate ?? '-'),
            ],
          ),
          const SizedBox(height: 16),

          // 담당 기관
          if (_main.agencyName != null) ...[
            _SectionTitle(title: '담당 기관'),
            const SizedBox(height: 8),
            _InfoCard(
              items: [
                _InfoItem(label: '기관명', value: _main.agencyName!),
                if (_main.contactPhone != null)
                  _InfoItem(label: '연락처', value: _main.contactPhone!),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // 원본 공고 PDF 버튼 (기능 8)
          if (_main.dtlUrl != null && _main.dtlUrl!.isNotEmpty)
            _PdfButton(url: _main.dtlUrl!),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// 헤더 카드
class _HeaderCard extends StatelessWidget {
  final NoticeDetailModel notice;

  const _HeaderCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 유형 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              notice.noticeType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 공고명
          Text(
            notice.noticeName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          // 위치
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '${notice.region} ${notice.city}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          if (notice.address != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                notice.address!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 공급 카드 (공급 유형별)
class _SupplyCard extends StatelessWidget {
  final NoticeDetailModel detail;

  const _SupplyCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.supplyType,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE5E9F0)),
            const SizedBox(height: 10),
            if (detail.supplyCount != null)
              _DetailRow(label: '공급 세대수', value: '${detail.supplyCount}세대'),
            if (detail.supplyArea != null)
              _DetailRow(label: '공급 면적', value: detail.supplyArea!),
            if (detail.minPrice != null || detail.maxPrice != null)
              _DetailRow(
                label: '분양가',
                value: _formatPrice(detail.minPrice, detail.maxPrice),
              ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int? min, int? max) {
    String formatWon(int won) {
      if (won >= 100000000) {
        final eok = won ~/ 100000000;
        final man = (won % 100000000) ~/ 10000;
        return man > 0 ? '$eok억 $man만원' : '$eok억원';
      }
      return '${won ~/ 10000}만원';
    }

    if (min != null && max != null && min != max) {
      return '${formatWon(min)} ~ ${formatWon(max)}';
    }
    if (min != null) return formatWon(min);
    if (max != null) return formatWon(max);
    return '-';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 타이틀
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// 정보 카드
class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}

/// PDF 원본 공고 버튼 (기능 8)
class _PdfButton extends StatelessWidget {
  final String url;

  const _PdfButton({required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('공고문을 열 수 없습니다.')),
              );
            }
          }
        },
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('원본 공고문 보기 (PDF)'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

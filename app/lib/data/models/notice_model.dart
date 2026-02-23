/// 공고 지도 마커용 모델 (mart_notice_map 기반)
class NoticeMapModel {
  final String noticeId;          // 공고 ID
  final String noticeName;        // 공고명
  final String noticeType;        // 공고 유형 (분양/임대/토지/상가)
  final String region;            // 지역 (시도)
  final String city;              // 시군구
  final double? latitude;         // 위도
  final double? longitude;        // 경도
  final String? startDate;        // 공고 시작일
  final String? closeDate;        // 공고 마감일
  final String? dtlUrl;           // 원본 공고 URL (PDF)
  final int? totalSupplyCount;    // 총 공급 세대수

  const NoticeMapModel({
    required this.noticeId,
    required this.noticeName,
    required this.noticeType,
    required this.region,
    required this.city,
    this.latitude,
    this.longitude,
    this.startDate,
    this.closeDate,
    this.dtlUrl,
    this.totalSupplyCount,
  });

  factory NoticeMapModel.fromJson(Map<String, dynamic> json) {
    return NoticeMapModel(
      noticeId: json['notice_id']?.toString() ?? '',
      noticeName: json['notice_name']?.toString() ?? '',
      noticeType: json['notice_type']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      startDate: json['start_date']?.toString(),
      closeDate: json['close_date']?.toString(),
      dtlUrl: json['dtl_url']?.toString(),
      totalSupplyCount: json['total_supply_count'] != null
          ? int.tryParse(json['total_supply_count'].toString())
          : null,
    );
  }

  /// 마감까지 남은 일수 계산
  int? get daysUntilClose {
    if (closeDate == null) return null;
    try {
      final close = DateTime.parse(closeDate!);
      final now = DateTime.now();
      return close.difference(now).inDays;
    } catch (_) {
      return null;
    }
  }

  /// 마감임박 여부 (7일 이내)
  bool get isUrgent {
    final days = daysUntilClose;
    return days != null && days >= 0 && days <= 7;
  }

  /// 신규 공고 여부 (3일 이내 등록)
  bool get isNew {
    if (startDate == null) return false;
    try {
      final start = DateTime.parse(startDate!);
      final now = DateTime.now();
      return now.difference(start).inDays <= 3;
    } catch (_) {
      return false;
    }
  }

  /// 공급 유형 코드 반환
  String get typeCode {
    if (noticeType.contains('임대')) return 'RENTAL';
    if (noticeType.contains('분양')) return 'HOUSING';
    if (noticeType.contains('토지')) return 'LAND';
    if (noticeType.contains('상가')) return 'STORE';
    return 'OTHER';
  }
}

/// 공고 상세 모델 (mart_notice_detail 기반)
class NoticeDetailModel {
  final String noticeId;
  final String noticeName;
  final String noticeType;
  final String supplyType;        // 공급 유형 세부
  final String region;
  final String city;
  final String? address;          // 상세 주소
  final double? latitude;
  final double? longitude;
  final String? startDate;
  final String? closeDate;
  final String? dtlUrl;
  final int? supplyCount;         // 공급 세대수
  final String? supplyArea;       // 공급면적
  final int? minPrice;            // 최소 분양가
  final int? maxPrice;            // 최대 분양가
  final String? agencyName;       // 담당 기관명
  final String? contactPhone;     // 연락처

  const NoticeDetailModel({
    required this.noticeId,
    required this.noticeName,
    required this.noticeType,
    required this.supplyType,
    required this.region,
    required this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.startDate,
    this.closeDate,
    this.dtlUrl,
    this.supplyCount,
    this.supplyArea,
    this.minPrice,
    this.maxPrice,
    this.agencyName,
    this.contactPhone,
  });

  factory NoticeDetailModel.fromJson(Map<String, dynamic> json) {
    return NoticeDetailModel(
      noticeId: json['notice_id']?.toString() ?? '',
      noticeName: json['notice_name']?.toString() ?? '',
      noticeType: json['notice_type']?.toString() ?? '',
      supplyType: json['supply_type']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      startDate: json['start_date']?.toString(),
      closeDate: json['close_date']?.toString(),
      dtlUrl: json['dtl_url']?.toString(),
      supplyCount: json['supply_count'] != null
          ? int.tryParse(json['supply_count'].toString())
          : null,
      supplyArea: json['supply_area']?.toString(),
      minPrice: json['min_price'] != null
          ? int.tryParse(json['min_price'].toString())
          : null,
      maxPrice: json['max_price'] != null
          ? int.tryParse(json['max_price'].toString())
          : null,
      agencyName: json['agency_name']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
    );
  }
}

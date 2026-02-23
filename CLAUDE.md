# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 코드를 다룰 때 따라야 할 지침과 프로젝트 개요를 제공합니다.

## 프로젝트 개요

이 프로젝트는 한국 공공데이터포털 API(한국토지주택공사(LH) 분양임대공고 정보)를 통해 수집한 데이터를 앱(어플리케이션)으로 개발하기위한 프로젝트입니다.

## 기술스텍

- Supabase
- Supabase edge function
- DBT
- GitHub Actions
- Flutter
- Dart


## Commands

**Run the ETL scripts locally:**
```bash
# 공고 목록 적재
python src/lh_notice_info_etl.py

# 공급정보 적재 (공고 목록 선행 필요)
python src/lh_spl_info_etl.py

# Geocoding 실행 (공급정보 선행 필요)
python src/lh_geocoding_etl.py
```

**Install dependencies:**
```bash
pip install -r src/requirements.txt
```

**DB 연결 테스트:**
```bash
python src/db_conn.py
```

## Environment Variables

- `DB_URL`: Database connection string (SQLAlchemy format)
- `SERVICE_KEY`: API key for the Korean Public Data Portal (data.go.kr)
- `KAKAO_API_KEY`: 카카오 REST API 키 (Geocoding용, developers.kakao.com)
- `PAN_NT_ST_DT`: 공고조회 검색 시작일 (YYYYMMDD)
- `CLSG_DT`: 공고조회 검색 종료일 (YYYYMMDD)

이 변수들은 자동화된 워크플로우를 위해 GitHub Secrets로 설정되어 있습니다.

## Architecture

**Data Flow:**
1. **[Step 1] 공고조회**: `lh_notice_info_etl.py` → 공고 목록 API 호출 (페이지네이션) → `ods_lh_lease_notice_info` 적재
2. **[Step 2] 공급정보**: `lh_spl_info_etl.py` → `ods_lh_lease_notice_info` 조회 → 공고별 Loop API 호출 → `ods_lh_lease_notice_spl_info` 적재
3. **[Step 3] Geocoding**: `lh_geocoding_etl.py` → 신규 주소 추출 → 카카오 API 호출 → `ods_geocoded_addresses` 적재
4. **[Step 4] DBT**: ODS → Staging → Intermediate → Marts (BI Star Schema + 앱용 Denormalized)

**Workflow 실행 순서:**
- `lh_notice_info_etl.yml` (매일 17:00 UTC) → 완료 후 → `lh_spl_info_etl.yml` (공급정보 + Geocoding 자동 트리거)

**Project Structure:**
```
lh-lease-notice-splInfo/
├── src/                              # ETL 소스 코드
│   ├── lh_notice_info_etl.py         # 공고조회 ETL (Step 1)
│   ├── lh_spl_info_etl.py            # 공급정보 ETL (Step 2)
│   ├── lh_geocoding_etl.py           # Geocoding ETL (Step 3)
│   ├── db_conn.py                    # DB 연결 테스트
│   └── requirements.txt              # Python 패키지 의존성
├── ddl/                              # 테이블 DDL
│   ├── ods_lh_lease_notice_info.sql
│   ├── ods_lh_lease_notice_spl_info.sql
│   └── ods_geocoded_addresses.sql    # Geocoding 결과 (별도 ODS)
├── models/                           # DBT 모델
│   ├── sources/sources.yml           # ODS 소스 정의
│   ├── staging/                      # Staging (table)
│   │   ├── stg_lh_notice_list.sql
│   │   ├── stg_lh_supply_info.sql
│   │   └── stg_geocoded_addresses.sql
│   ├── intermediate/                 # Intermediate (view)
│   │   ├── int_lh_supply_land.sql
│   │   ├── int_lh_supply_housing.sql
│   │   ├── int_lh_supply_rental.sql
│   │   └── int_lh_supply_store.sql
│   └── marts/                        # Marts (table)
│       ├── bi/                       # BI용 Star Schema
│       │   ├── fact_notice_supply.sql
│       │   ├── dim_notice.sql
│       │   ├── dim_region.sql
│       │   ├── dim_supply_type.sql
│       │   ├── dim_date.sql
│       │   └── schema.yml
│       └── app/                      # 앱용 Denormalized
│           ├── mart_notice_map.sql   # 지도 마커용 (공고당 1행)
│           ├── mart_notice_detail.sql # 상세 페이지용 (공급건별)
│           └── schema.yml
├── macros/                           # DBT 매크로
│   └── type_cast.sql
├── documents/                        # API 활용가이드 PDF
├── .github/workflows/                # GitHub Actions 워크플로우
│   ├── lh_notice_info_etl.yml        # 공고조회 파이프라인
│   └── lh_spl_info_etl.yml          # 공급정보 + Geocoding 파이프라인
├── .env                              # 환경변수 (로컬 전용, .gitignore)
└── CLAUDE.md                         # 프로젝트 지침서
```

**ODS 테이블 구조 (분리 전략):**
```
ODS
├─ ods_lh_lease_notice_info         (원본 - 공고조회)
├─ ods_lh_lease_notice_spl_info     (원본 - 공급정보)
└─ ods_geocoded_addresses           (별도 - Geocoding 결과)
```
- ODS 원본 데이터 순수성 유지
- Geocoding 이력 관리 및 실패 주소 추적 가능
- 여러 소스 데이터에서 재사용 가능

**Marts 구조 (이중 용도):**
```
Marts
├── bi/   (Star Schema → BI 도구 연동)
│   ├── fact_notice_supply     # 팩트: 공급 측정값
│   ├── dim_notice             # 차원: 공고
│   ├── dim_region             # 차원: 지역
│   ├── dim_supply_type        # 차원: 공급유형
│   └── dim_date               # 차원: 날짜
└── app/  (Denormalized → 앱 API 연동)
    ├── mart_notice_map        # 지도 마커용
    └── mart_notice_detail     # 상세 페이지용
```

## Known Issues

- DB 연결은 Supabase Transaction Pooler(PgBouncer, port 6543)를 사용합니다. `create_engine`에 `pool_pre_ping=True` 옵션이 필수입니다.
- API 응답 구조가 SPL_INF_TP_CD 값에 따라 다릅니다. 현재 코드는 dsList01~dsList03을 통합하여 적재합니다.

## Code Style

- 모든 Agent의 답변은 한국어로 해주세요.
- 작업 시작 시 현재 지침서를 확인 후 진행하세요.
- Python 코드를 작성할 때는 PEP8 가이드(https://peps.python.org/pep-0008/) 및 스타일을 준수해주세요.
- Javascript 코드를 작성할 때는 ES6+ 문법을 사용해주세요.
- 프로젝트의 전체적인 맥락과 레이아웃을 유지하여 코드를 작성해주세요.
- 주석, 코멘트는 한국어로 작성해주세요.
- 작업 진행 시에는 먼저 전체 로직을 파악한 후 고려하여 진행해주세요.
- Github Actions를 사용할 때는 .github/workflows/ 폴더를 확인해주세요.
- Update Todos를 진행할 때는 사전에 프로그램 전체 로직을 파악한 후 진행해주세요.

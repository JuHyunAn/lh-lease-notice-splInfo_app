-- 앱 상세 페이지용 마트 (공급건별 1행)
-- 앱의 mart_notice_detail 테이블과 컬럼 1:1 매핑
{{ config(materialized='table') }}

WITH notices AS (
    SELECT * FROM {{ ref('stg_lh_notice_list') }}
),

supply AS (
    SELECT * FROM {{ ref('stg_lh_supply_info') }}
),

geo AS (
    SELECT * FROM {{ ref('stg_geocoded_addresses') }}
)

SELECT
    s.notice_id,
    n.notice_name,
    n.notice_type,
    -- 세부 공급유형: supply_type_name 우선, 없으면 notice_type 사용
    COALESCE(NULLIF(n.supply_type_name, ''), n.notice_type)    AS supply_type,
    n.region,
    COALESCE(s.city, '')                                       AS city,
    s.address,
    g.latitude,
    g.longitude,
    n.start_date,
    n.close_date,
    n.dtl_url,
    -- 공급 세대수: 총세대 → 일반공급 순으로
    COALESCE(s.total_household_count, s.general_household_count) AS supply_count,
    s.supply_area,
    -- 최소가: 일반공급금액 → 공급예정금액 순으로
    COALESCE(s.general_price, s.expected_price)                AS min_price,
    NULL::bigint                                               AS max_price,
    -- 담당기관: 공고명으로 대체 (원본 데이터에 없음)
    n.notice_name                                              AS agency_name,
    NULL::text                                                 AS contact_phone

FROM supply s
LEFT JOIN notices n ON n.notice_id = s.notice_id
LEFT JOIN geo g     ON g.address   = s.address

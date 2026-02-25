-- 앱 지도 마커용 마트 (공고당 1행)
-- 앱의 mart_notice_map 테이블과 컬럼 1:1 매핑
{{ config(materialized='table') }}

WITH notices AS (
    SELECT * FROM {{ ref('stg_lh_notice_list') }}
),

-- 공급정보에서 공고별 집계 (첫 번째 주소 + 총 공급수)
supply_summary AS (
    SELECT
        notice_id,
        COUNT(*)                                                AS total_supply_count,
        MAX(city)                                              AS city,
        -- 지오코딩에 사용할 대표 주소 (첫 번째 유효 주소)
        MIN(address) FILTER (WHERE address IS NOT NULL)        AS address
    FROM {{ ref('stg_lh_supply_info') }}
    GROUP BY notice_id
),

geo AS (
    SELECT * FROM {{ ref('stg_geocoded_addresses') }}
)

SELECT
    n.notice_id,
    n.notice_name,
    n.notice_type,
    n.region,
    COALESCE(s.city, '')                    AS city,
    g.latitude,
    g.longitude,
    n.start_date,
    n.close_date,
    n.dtl_url,
    COALESCE(s.total_supply_count, 0)::integer AS total_supply_count

FROM notices n
LEFT JOIN supply_summary s  ON s.notice_id  = n.notice_id
LEFT JOIN geo g             ON g.address    = s.address

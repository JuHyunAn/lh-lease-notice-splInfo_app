-- 공급 정보 스테이징 모델
-- ods_lh_lease_notice_spl_info 정제 (dsList01~03 통합 구조)
{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'ods_lh_lease_notice_spl_info') }}
)

SELECT
    id,
    "PAN_ID"                AS notice_id,
    "SPL_INF_TP_CD"         AS spl_type_cd,
    "UPP_AIS_TP_CD"         AS upp_type_cd,
    "AIS_TP_CD"             AS supply_type_cd,
    data_type,              -- dsList01(토지), dsList02(주택), dsList03(임대)

    -- 주소: data_type별로 필드가 다름 → COALESCE로 통합
    COALESCE(
        NULLIF(trim("LGDN_DTL_ADR"), ''),   -- 토지 소재지
        NULLIF(trim("DNG_HS_ADR"), ''),     -- 주택 동호 주소
        NULLIF(trim("SBD_LGO_ADR"), ''),    -- 단지 주소
        NULLIF(trim("ADR"), '')             -- 일반 주소
    )                       AS address,

    NULLIF(trim("SGG_NM"), '')  AS city,   -- 시군구명

    -- 면적 (숫자 문자열 → numeric)
    CASE WHEN "AR" ~ '^[0-9.]+$'     THEN "AR"::numeric     ELSE NULL END AS land_area,
    NULLIF(trim("SPL_AR"), '')      AS supply_area,

    -- 세대수 (숫자 문자열 → integer)
    CASE WHEN "TOT_HSH_CNT" ~ '^[0-9]+$' THEN "TOT_HSH_CNT"::integer ELSE NULL END AS total_household_count,
    CASE WHEN "SIL_HSH_CNT" ~ '^[0-9]+$' THEN "SIL_HSH_CNT"::integer ELSE NULL END AS general_household_count,

    -- 금액 (숫자 문자열 → bigint)
    CASE WHEN "SPL_XPC_AMT" ~ '^[0-9]+$' THEN "SPL_XPC_AMT"::bigint ELSE NULL END AS expected_price,
    CASE WHEN "SIL_AMT"     ~ '^[0-9]+$' THEN "SIL_AMT"::bigint     ELSE NULL END AS general_price,
    NULLIF(trim("LS_GMY"), '') AS lease_deposit,
    NULLIF(trim("MM_RFE"), '') AS monthly_rent,

    -- 주택 관련
    NULLIF(trim("HTY_NM"), '')      AS housing_type,
    NULLIF(trim("SBD_LGO_NM"), '')  AS complex_name,

    created_at
FROM source

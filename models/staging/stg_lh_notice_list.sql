-- 공고 목록 스테이징 모델
-- ods_lh_lease_notice_info에서 공고당 1행만 추출 (중복 제거) + 컬럼명/타입 정제
{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'ods_lh_lease_notice_info') }}
),

-- 공고 ID 기준 최신 적재 행만 선택 (페이지네이션 중복 제거)
deduplicated AS (
    SELECT DISTINCT ON ("PAN_ID")
        "PAN_ID"            AS notice_id,
        "PAN_NM"            AS notice_name,
        "PAN_SS"            AS notice_status,
        "UPP_AIS_TP_NM"     AS notice_type,       -- 상위 공급유형 (주택/상가/토지)
        "AIS_TP_CD"         AS supply_type_cd,
        "AIS_TP_CD_NM"      AS supply_type_name,   -- 세부 공급유형명
        "SPL_INF_TP_CD"     AS spl_type_cd,
        "CCR_CNNT_SYS_DS_CD" AS system_cd,
        "CNP_CD_NM"         AS region,             -- 시도명
        -- 날짜 형식 변환: '2026.02.24' → '2026-02-24'
        replace("PAN_NT_ST_DT", '.', '-')  AS start_date,
        replace("CLSG_DT", '.', '-')       AS close_date,
        "DTL_URL"           AS dtl_url,
        created_at
    FROM source
    ORDER BY "PAN_ID", created_at DESC
)

SELECT * FROM deduplicated

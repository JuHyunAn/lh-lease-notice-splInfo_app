-- 지오코딩 결과 스테이징 모델 (성공 건만)
{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'ods_geocoded_addresses') }}
)

SELECT
    address,
    latitude::double precision   AS latitude,
    longitude::double precision  AS longitude,
    geocoded_address,
    geocoding_source,
    geocoded_at
FROM source
WHERE is_success = true
  AND latitude  IS NOT NULL
  AND longitude IS NOT NULL

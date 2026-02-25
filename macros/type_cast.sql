-- 숫자 문자열을 안전하게 캐스팅하는 매크로
{% macro safe_int(column) %}
    CASE WHEN {{ column }} ~ '^[0-9]+$' THEN {{ column }}::integer ELSE NULL END
{% endmacro %}

{% macro safe_bigint(column) %}
    CASE WHEN {{ column }} ~ '^[0-9]+$' THEN {{ column }}::bigint ELSE NULL END
{% endmacro %}

{% macro safe_numeric(column) %}
    CASE WHEN {{ column }} ~ '^[0-9.]+$' THEN {{ column }}::numeric ELSE NULL END
{% endmacro %}

-- LH API 날짜 형식(YYYY.MM.DD) → ISO 형식(YYYY-MM-DD) 변환
{% macro lh_date(column) %}
    replace({{ column }}, '.', '-')
{% endmacro %}

SELECT
  calls_ivr_id,
  CASE
    WHEN STARTS_WITH(calls_vdn_label, 'ATC') THEN 'FRONT'
    WHEN STARTS_WITH(calls_vdn_label, 'TECH') THEN 'TECH'
    WHEN calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
    ELSE 'RESTO'
  END AS vdn_aggregation
FROM
  keepcoding.ivr_detail
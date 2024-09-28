SELECT
  calls_ivr_id,
  customer_phone
FROM
  keepcoding.ivr_detail
WHERE
  customer_phone <>'UNKNOWN'
QUALIFY
  ROW_NUMBER() OVER(PARTITION BY CAST(calls_ivr_id AS STRING)) = 1
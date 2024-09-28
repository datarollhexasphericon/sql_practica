SELECT
  calls_ivr_id,
  billing_account_id
FROM
  keepcoding.ivr_detail
WHERE
  billing_account_id <>'UNKNOWN'
QUALIFY
  ROW_NUMBER() OVER(PARTITION BY CAST(calls_ivr_id AS STRING)) = 1
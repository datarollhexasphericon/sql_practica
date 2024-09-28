SELECT
  calls_ivr_id,
  document_type,
  document_identification
FROM
  keepcoding.ivr_detail
WHERE
  document_identification <>'UNKNOWN'
  AND
  document_type NOT IN ('UNKNOWN', 'DESCONOCIDO')
QUALIFY
  ROW_NUMBER() OVER(PARTITION BY CAST(calls_ivr_id AS STRING)) = 1
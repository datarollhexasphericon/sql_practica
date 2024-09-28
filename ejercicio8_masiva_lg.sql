SELECT 
  calls_ivr_id, 
  MAX(IF(module_name = 'AVERIA_MASIVA', 1, 0)) AS masiva_lg
FROM keepcoding.ivr_detail
GROUP BY calls_ivr_id;
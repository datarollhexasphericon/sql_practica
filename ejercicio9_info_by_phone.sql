SELECT 
  calls_ivr_id, 
  MAX(CASE WHEN step_name = 'CUSTOMERINFOBYPHONE.TX' AND step_result = 'OK' THEN 1 ELSE 0 END) AS info_by_phone_lg
FROM keepcoding.ivr_detail
GROUP BY calls_ivr_id;
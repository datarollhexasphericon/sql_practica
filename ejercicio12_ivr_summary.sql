CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
  WITH
    vdn_agg AS (
    SELECT
      calls_ivr_id,
      CASE
        WHEN STARTS_WITH(calls_vdn_label, 'ATC') THEN 'FRONT'
        WHEN STARTS_WITH(calls_vdn_label, 'TECH') THEN 'TECH'
        WHEN calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
        ELSE 'RESTO' END AS vdn_aggregation
    FROM
      keepcoding.ivr_detail
      ),
      
    document_info AS (
      SELECT
        calls_ivr_id,
        document_type,
        document_identification
      FROM
        keepcoding.ivr_detail
      WHERE
        document_identification <>'UNKNOWN'
        AND document_type NOT IN ('UNKNOWN','DESCONOCIDO')
      QUALIFY
        ROW_NUMBER() OVER(PARTITION BY CAST(calls_ivr_id AS STRING)) = 1
      ),

    phone_info AS (
      SELECT
        calls_ivr_id,
        customer_phone
      FROM
        keepcoding.ivr_detail
      WHERE
        customer_phone <>'UNKNOWN'
      QUALIFY
        ROW_NUMBER() OVER(PARTITION BY CAST(calls_ivr_id AS STRING)) = 1
      ),

    billing_info AS (
      SELECT
        calls_ivr_id,
        billing_account_id
      FROM
        keepcoding.ivr_detail
      WHERE
        billing_account_id <>'UNKNOWN'
      QUALIFY
        ROW_NUMBER() OVER(PARTITION BY CAST(calls_ivr_id AS STRING)) = 1
      ),

    massiva AS (
      SELECT 
        calls_ivr_id, 
        MAX(IF(module_name = 'AVERIA_MASIVA', 1, 0)) AS masiva_lg
      FROM keepcoding.ivr_detail
      GROUP BY calls_ivr_id
    ),

    info_by_phone AS (
      SELECT 
        calls_ivr_id, 
        MAX(CASE WHEN step_name = 'CUSTOMERINFOBYPHONE.TX' AND step_result = 'OK' THEN 1 ELSE 0 END) AS info_by_phone_lg
      FROM keepcoding.ivr_detail
      GROUP BY calls_ivr_id
    ),

    info_by_dni AS (
      SELECT 
        calls_ivr_id, 
        MAX(CASE WHEN step_name = 'CUSTOMERINFOBYDNI.TX' AND step_result = 'OK' THEN 1 ELSE 0 END) AS info_by_dni_lg
      FROM keepcoding.ivr_detail
      GROUP BY calls_ivr_id
    ),

    call_analysis AS (
      WITH grouped_calls AS (
        SELECT
          calls_ivr_id,
          calls_phone_number,
          calls_start_date
        FROM
          keepcoding.ivr_detail
        GROUP BY
          calls_phone_number,
          calls_ivr_id,
          calls_start_date)
          
      SELECT
        calls_ivr_id,
        calls_phone_number,
      IF
        (DATETIME_DIFF(calls_start_date, previous_call_date, HOUR) < 24, 1, 0) AS repeated_phone_24H,
      IF
        (DATETIME_DIFF(next_call_date, calls_start_date, HOUR) < 24, 1, 0) AS cause_recall_phone_24H
      FROM (
        SELECT
          calls_ivr_id,
          calls_phone_number,
          calls_start_date,
          LAG(calls_start_date) OVER(PARTITION BY calls_phone_number ORDER BY calls_start_date) AS previous_call_date,
          LEAD(calls_start_date) OVER(PARTITION BY calls_phone_number ORDER BY calls_start_date) AS next_call_date
        FROM
          grouped_calls
        ORDER BY
          calls_phone_number) AS subq
    )

  SELECT DISTINCT
    detail.calls_ivr_id,
    detail.calls_phone_number,
    detail.calls_ivr_result,
    vdn_agg.vdn_aggregation,
    detail.calls_start_date,
    detail.calls_end_date,
    detail.calls_total_duration,
    detail.calls_customer_segment,
    detail.calls_ivr_language,
    detail.calls_steps_module,
    detail.calls_module_aggregation,
    document_info.document_type,
    document_info.document_identification,
    phone_info.customer_phone,
    billing_info.billing_account_id,
    massiva.masiva_lg,
    info_by_phone.info_by_phone_lg,
    info_by_dni.info_by_dni_lg,
    call_analysis.repeated_phone_24H,
    call_analysis.cause_recall_phone_24H
  FROM
    keepcoding.ivr_detail AS detail
  LEFT JOIN vdn_agg ON vdn_agg.calls_ivr_id = detail.calls_ivr_id
  LEFT JOIN document_info ON document_info.calls_ivr_id = detail.calls_ivr_id
  LEFT JOIN phone_info ON phone_info.calls_ivr_id = detail.calls_ivr_id
  LEFT JOIN billing_info ON billing_info.calls_ivr_id = detail.calls_ivr_id
  LEFT JOIN massiva ON massiva.calls_ivr_id = detail.calls_ivr_id
  LEFT JOIN info_by_phone ON info_by_phone.calls_ivr_id = detail.calls_ivr_id
  LEFT JOIN info_by_dni ON info_by_dni.calls_ivr_id = detail.calls_ivr_id
  LEFT JOIN call_analysis ON call_analysis.calls_ivr_id = detail.calls_ivr_id;

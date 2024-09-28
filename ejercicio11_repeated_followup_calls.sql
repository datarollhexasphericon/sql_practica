CREATE TABLE keepcoding.call_analysis AS
WITH
  grouped_calls AS (
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
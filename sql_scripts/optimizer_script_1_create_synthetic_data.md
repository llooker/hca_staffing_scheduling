```
/**********************
Purpose: Create optimizer for scheduling / staffing use case
Step 1: Create Synthetic Data
Author: Aaron Wilkowitz
Date Created: 2021-11-30
**********************/

------ Create shifts --------

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_1_create_rows` AS
          SELECT 1 as value
UNION ALL SELECT 2 as value
UNION ALL SELECT 3 as value
UNION ALL SELECT 4 as value
UNION ALL SELECT 5 as value
UNION ALL SELECT 6 as value
UNION ALL SELECT 7 as value
UNION ALL SELECT 8 as value
UNION ALL SELECT 9 as value
UNION ALL SELECT 10 as value
;

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_2_create_shifts` AS
with shift_cte as (
SELECT
    row_number() over (partition by 'x') as shift_id
FROM `hca-data-sandbox.staffing_scheduling.optimizer_1_create_rows` a -- 10
CROSS JOIN `hca-data-sandbox.staffing_scheduling.optimizer_1_create_rows` b -- 100
LIMIT 58
)
, shift_time_cte as (
SELECT
    shift_id
  , timestamp_add(cast(current_date || ' 7:00:00.00 UTC' as timestamp), interval 12 * (shift_id - 1) hour) as shift_timestamp
FROM shift_cte
)
, shift_dow_time_cte as (
SELECT
    *
  , extract(dayofweek from shift_timestamp) as day_of_week
  , case when extract(hour from shift_timestamp) < 12 then 'AM' else 'PM' end as time_of_day
FROM shift_time_cte
),
shift_weekend_cte as (
SELECT
    *
  , case when day_of_week in (7,1) or (day_of_week = 6 and time_of_day = 'PM') then 1 else 0 end as is_weekend
FROM shift_dow_time_cte
)
SELECT
    *
  , round(case
      when is_weekend = 1 and time_of_day = 'PM' then 38 * 0.4 * (1 + (rand()-0.5))
      when is_weekend = 0 and time_of_day = 'PM' then 38 * 0.7 * (1 + (rand()-0.5))
      when is_weekend = 1 and time_of_day = 'AM' then 38 * 0.8 * (1 + (rand()-0.5))
      when is_weekend = 0 and time_of_day = 'AM' then 38 * 1 *   (1 + (rand()-0.5))
    end, 0) as staff_required
FROM shift_weekend_cte
;

/*
-- Validation - this should average about 30, never more than 60
SELECT avg(staff_required), min(staff_required), max(staff_required)
FROM `hca-data-sandbox.staffing_scheduling.optimizer_2_create_shifts`
;
*/

------ Create staff --------

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_3_create_staff` AS
with staff_id_cte as (
SELECT
    row_number() over (partition by 'x') as staff_id
FROM `hca-data-sandbox.staffing_scheduling.optimizer_1_create_rows` a -- 10
CROSS JOIN `hca-data-sandbox.staffing_scheduling.optimizer_1_create_rows` b -- 100
LIMIT 60
)
SELECT
    *
  , case
      when rand() < 0.33 then 'A'
      when rand() < 0.66 then 'B'
      else 'C'
    end as status
  , round(staff_id / 3,0) as tenure
  , 25 as min_shifts
  , 35 as max_shifts
FROM staff_id_cte
;


------ Create preference by DOW by day / evening by staff --------
-- Only 50% of staff fill this out

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_4_dow_tod_preferences` AS
with cross_join_cte as (
  SELECT
      *
    , case when rand() < 0.5 then 1 else 0 end as filled_out
    , rand() as rand_preference
  FROM
  (
  SELECT
    distinct staff_id
  FROM `hca-data-sandbox.staffing_scheduling.optimizer_3_create_staff`
  ) a
  , (
  SELECT
    distinct day_of_week, time_of_day, is_weekend
  FROM `hca-data-sandbox.staffing_scheduling.optimizer_2_create_shifts`
  ) b
)
SELECT
    staff_id
  , day_of_week
  , time_of_day
  , case
      when filled_out = 0 then 0
      when is_weekend = 1 and time_of_day = 'PM' and rand() < 0.1 then 1
      when is_weekend = 0 and time_of_day = 'PM' and rand() < 0.3 then 1
      when is_weekend = 1 and time_of_day = 'AM' and rand() < 0.9 then 1
      when is_weekend = 0 and time_of_day = 'AM' and rand() < 0.3 then 1
      else -1
    end as preference
FROM cross_join_cte
;

------ Create 4 unavailable shifts by staff --------
-- 80% filled out

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_5_unavailable_shifts` AS
with cross_join_cte as (
  SELECT
      *
    , case when rand() < 0.8 then 1 else 0 end as filled_out
    , rand() as rand_preference
  FROM
  (
  SELECT
    distinct staff_id
  FROM `hca-data-sandbox.staffing_scheduling.optimizer_3_create_staff`
  ) a
  , (
  SELECT
    distinct shift_id
  FROM `hca-data-sandbox.staffing_scheduling.optimizer_2_create_shifts`
  ) b
)
, rank_cte as (
SELECT
    *
  , row_number() over (partition by staff_id order by rand_preference) as rank
FROM cross_join_cte
)
SELECT
    staff_id
  , shift_id
  , case when filled_out = 1 and rank <= 4 then 1 else 0 end as is_unavailable
FROM rank_cte
;

------ Create choices by staff  --------
-- For 50% of people - they choose 30 slots
-- For 25% of people - they choose 15 slots
-- For 25% of people - they choose 0 slots

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_6_preferred_shifts` AS
with cross_join_cte as (
  SELECT
      *
    , case when rand() < 0.5 then 1 when rand() < 0.75 then 0.5 else 0 end as filled_out
    , rand() as rand_preference
  FROM
  (
  SELECT
    distinct staff_id
  FROM `hca-data-sandbox.staffing_scheduling.optimizer_3_create_staff`
  ) a
  , (
  SELECT
    distinct shift_id
  FROM `hca-data-sandbox.staffing_scheduling.optimizer_2_create_shifts`
  ) b
)
, rank_cte as (
SELECT
    *
  , row_number() over (partition by staff_id order by rand_preference) as rank
FROM cross_join_cte
)
SELECT
    staff_id
  , shift_id
  , case
      when filled_out = 1 and rank <= 30 then 1
      when filled_out = 0.5 and rank <= 15 then 1
      else 0
    end as is_preferred_slot
FROM rank_cte
;

------ Make a final table of staff & shifts  --------

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_7_staff_shifts_combined` AS
with shift_staff_cte as (
SELECT
    a.*
  , b.*
FROM `hca-data-sandbox.staffing_scheduling.optimizer_2_create_shifts` a
, `hca-data-sandbox.staffing_scheduling.optimizer_3_create_staff` b
)
SELECT
    a.*
  , b.preference as dow_tod_preference
  , c.is_unavailable
  , d.is_preferred_slot
  , 0 as is_staffed
FROM shift_staff_cte a
LEFT JOIN `hca-data-sandbox.staffing_scheduling.optimizer_4_dow_tod_preferences` b
  ON a.staff_id = b.staff_id
  AND a.day_of_week = b.day_of_week
  AND a.time_of_day = b.time_of_day
LEFT JOIN `hca-data-sandbox.staffing_scheduling.optimizer_5_unavailable_shifts` c
  ON a.staff_id = c.staff_id
  AND a.shift_id = c.shift_id
LEFT JOIN `hca-data-sandbox.staffing_scheduling.optimizer_6_preferred_shifts` d
  ON a.staff_id = d.staff_id
  AND a.shift_id = d.shift_id
;
```

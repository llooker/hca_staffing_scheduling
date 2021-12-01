```
/**********************
Purpose: Create optimizer for scheduling / staffing use case
Step 2: Run Optimizer
Author: Aaron Wilkowitz
Date Created: 2021-11-30

-- Start by assuming 0 shifts are scheduled
-- Schedule each shift incrementally
**********************/

-- Declare variable

DECLARE counter INT64 DEFAULT 0 ;
  -- 0 ;
  -- (SELECT max(counter_id) - 1 FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer`) ;

-- Put synthetic data in a new table

/*
CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer` AS
SELECT *
  , NULL as counter_id
  , NULL as staff_applied
  , NULL as staff_outstanding
  , NULL as shift_required
  , NULL as shift_applied
  , NULL as shift_outstanding
  , NULL as score_unavailable
  , NULL as score_preferred
  , NULL as score_dow_tod
  , NULL as score_shifts_outstanding
  , NULL as score_rank
  , NULL as score_two_consecutive
  , NULL as score_three_consecutive
  , NULL as score_five_day_shift
  , NULL as score_nine_day_shift
  , NULL as grand_total
FROM `hca-data-sandbox.staffing_scheduling.optimizer_7_staff_shifts_combined`
;
*/

-- Set counter for loop

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_100_set_counter` AS
with shift_id_cte as (
SELECT
    shift_id
  , max(staff_required) as staff_required
FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer`
GROUP BY 1
)
SELECT sum(staff_required) as max_counter
FROM shift_id_cte
;

-- Start loop

LOOP

-- Add 1 to counter

  SET counter = counter + 1;
  IF counter > (SELECT max_counter FROM `hca-data-sandbox.staffing_scheduling.optimizer_100_set_counter`)
    THEN LEAVE;
  END IF;

-- Which single shift is in most dire need of filling?

-- DECLARE counter INT64 DEFAULT 0;
CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_101_select_shift` AS
with staffing_required_cte as (
SELECT
    shift_id
  , max(staff_required) as staff_required
  , sum(is_staffed) as staff_applied
FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer`
GROUP BY 1
)
, staff_outstanding_cte as (
SELECT
    shift_id
  , staff_required
  , staff_applied
  , staff_required - staff_applied as staff_outstanding
  ## Note: this would be partitioned by hospital with real data
  , row_number() over (partition by 'x' order by staff_required - staff_applied desc, shift_id) as rank
FROM staffing_required_cte
)
SELECT
    shift_id
  , staff_required
  , staff_applied
  , staff_outstanding
  , rank
FROM staff_outstanding_cte
WHERE rank = 1
;

-- Which staff are generally in most dire need of adding a shift?
  -- In tiebreaker, reference status first, then tenure

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_102_staff_rank` AS
with shifts_required_cte as (
SELECT
    staff_id
  , status
  , tenure
  , max(min_shifts) as shifts_required
  , sum(is_staffed) as shifts_applied
FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer`
GROUP BY 1,2,3
)
, shifts_outstanding_cte as (
SELECT
    staff_id
  , shifts_required
  , shifts_applied
  , shifts_required - shifts_applied as shifts_outstanding
  , row_number() over (partition by 'x' order by shifts_required - shifts_applied desc, status asc, tenure desc) as rank
FROM shifts_required_cte
)
SELECT
    staff_id
  , shifts_required as shift_required
  , shifts_applied as shift_applied
  , shifts_outstanding as shift_outstanding
  , rank
FROM shifts_outstanding_cte
;

-- Calculate consecutive shifts & busy shifts

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_103_consecutive_shifts` AS
with consecutive_cte as (
SELECT
    staff_id
  , shift_id
  , is_staffed
  , coalesce(lead(is_staffed,1) OVER (PARTITION BY staff_id ORDER BY shift_id),0) as one_following
  , coalesce(lead(is_staffed,2) OVER (PARTITION BY staff_id ORDER BY shift_id),0) as two_following
  , coalesce(lag(is_staffed,1) OVER (PARTITION BY staff_id ORDER BY shift_id),0) as one_prior
  , coalesce(lag(is_staffed,2) OVER (PARTITION BY staff_id ORDER BY shift_id),0) as two_prior
  , sum(is_staffed) OVER (PARTITION BY staff_id ORDER BY shift_id ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) as five_day_view
  , sum(is_staffed) OVER (PARTITION BY staff_id ORDER BY shift_id ROWS BETWEEN 4 PRECEDING AND 4 FOLLOWING) as nine_day_view
FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer` a
ORDER BY 1,2
)
SELECT
    staff_id
  , shift_id
  , case when one_prior = 1 or one_following = 1 then 1 else 0 end as would_be_two_consecutive
  , case
      when
           (one_prior = 1 and one_following = 1)
        or (one_prior = 1 and two_prior = 1)
        or (one_following = 1 and two_following = 1)
      then 1 else 0 end as would_be_three_consecutive
  , round((five_day_view + 1) / 5,2) as would_be_x_shifts_per_day_in_5_days
  , round((nine_day_view + 1) / 9,2) as would_be_x_shifts_per_day_in_9_days
FROM consecutive_cte
;
-- Which staff person is best for the most dire shift?

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_104_select_staff` AS
with sub_total_cte as
(
SELECT
    a.shift_id
  , a.staff_id
  , b.staff_applied
  , b.staff_outstanding
  , c.shift_required
  , c.shift_applied
  , c.shift_outstanding
  , case when a.is_unavailable = 1 then -9999 else 0 end as score_unavailable
  , case when a.is_preferred_slot = 1 then 1000 else 0 end as score_preferred
  , a.dow_tod_preference * 100 as score_dow_tod
  , c.shift_outstanding * 100 as score_shifts_outstanding
  , c.rank * -10 as score_rank
  , d.would_be_two_consecutive * -100 as score_two_consecutive
  , d.would_be_three_consecutive * -10000 as score_three_consecutive
  , case
      when d.would_be_x_shifts_per_day_in_5_days > 1.25 then -500
      when d.would_be_x_shifts_per_day_in_5_days > 1 then -400
      when d.would_be_x_shifts_per_day_in_5_days > 0.75 then -300
      else 0
    end as score_five_day_shift
  , case
      when d.would_be_x_shifts_per_day_in_9_days > 1 then -500
      when d.would_be_x_shifts_per_day_in_9_days > 0.75 then -400
      when d.would_be_x_shifts_per_day_in_9_days > 0.6 then -300
      else 0
    end as score_nine_day_shift
FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer` a
INNER JOIN `hca-data-sandbox.staffing_scheduling.optimizer_101_select_shift` b
  ON a.shift_id = b.shift_id
LEFT JOIN `hca-data-sandbox.staffing_scheduling.optimizer_102_staff_rank` c
  ON a.staff_id = c.staff_id
LEFT JOIN `hca-data-sandbox.staffing_scheduling.optimizer_103_consecutive_shifts` d
  ON a.staff_id = d.staff_id
  AND a.shift_id = d.shift_id
WHERE is_staffed = 0
)
, grand_total_cte as
(
SELECT
    shift_id
  , staff_id
  , staff_applied
  , staff_outstanding
  , shift_required
  , shift_applied
  , shift_outstanding
  , score_unavailable
  , score_preferred
  , score_dow_tod
  , score_shifts_outstanding
  , score_rank
  , score_two_consecutive
  , score_three_consecutive
  , score_five_day_shift
  , score_nine_day_shift
  , score_unavailable + score_preferred + score_dow_tod + score_shifts_outstanding + score_rank
      + score_two_consecutive + score_three_consecutive + score_five_day_shift + score_nine_day_shift as grand_total
FROM sub_total_cte
),
rank_cte as
(
SELECT
    *
  , row_number() over (partition by 'x' order by grand_total desc) as rank
FROM grand_total_cte
)
SELECT
  *
FROM rank_cte
WHERE rank = 1
;

-- Update the staff - shift value

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer` AS
SELECT
    a.*
      except(
          is_staffed
        , counter_id
        , staff_required
        , staff_applied
        , staff_outstanding
        , shift_required
        , shift_applied
        , shift_outstanding
        , score_unavailable
        , score_preferred
        , score_dow_tod
        , score_shifts_outstanding
        , score_rank
        , score_two_consecutive
        , score_three_consecutive
        , score_five_day_shift
        , score_nine_day_shift
        , grand_total
      )
  , case when b.staff_id is not null then 1 else a.is_staffed end as is_staffed
  , case when b.staff_id is not null then counter else a.counter_id end as counter_id
  , staff_required
  , case when b.shift_id is not null then b.staff_applied else a.staff_applied end as staff_applied
  , case when b.shift_id is not null then b.staff_outstanding else a.staff_outstanding end as staff_outstanding
  , case when b.staff_id is not null then b.shift_required else a.shift_required end as shift_required
  , case when b.staff_id is not null then b.shift_applied else a.shift_applied end as shift_applied
  , case when b.staff_id is not null then b.shift_outstanding else a.shift_outstanding end as shift_outstanding
  , case when b.staff_id is not null then b.score_unavailable else a.score_unavailable end as score_unavailable
  , case when b.staff_id is not null then b.score_preferred else a.score_preferred end as score_preferred
  , case when b.staff_id is not null then b.score_dow_tod else a.score_dow_tod end as score_dow_tod
  , case when b.staff_id is not null then b.score_shifts_outstanding else a.score_shifts_outstanding end as score_shifts_outstanding
  , case when b.staff_id is not null then b.score_rank else a.score_rank end as score_rank
  , case when b.staff_id is not null then b.score_two_consecutive else a.score_two_consecutive end as score_two_consecutive
  , case when b.staff_id is not null then b.score_three_consecutive else a.score_three_consecutive end as score_three_consecutive
  , case when b.staff_id is not null then b.score_five_day_shift else a.score_five_day_shift end as score_five_day_shift
  , case when b.staff_id is not null then b.score_nine_day_shift else a.score_nine_day_shift end as score_nine_day_shift
  , case when b.staff_id is not null then b.grand_total else a.grand_total end as grand_total
FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer` a
LEFT JOIN `hca-data-sandbox.staffing_scheduling.optimizer_104_select_staff` b
  ON a.staff_id = b.staff_id
  AND a.shift_id = b.shift_id
-- LEFT JOIN `hca-data-sandbox.staffing_scheduling.optimizer_101_select_shift` c
--   ON a.shift_id = c.shift_id
-- LEFT JOIN `hca-data-sandbox.staffing_scheduling.optimizer_102_staff_rank` d
--   ON a.staff_id = d.staff_id

;

-- End loop

END LOOP;

/*
SELECT *
FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer`
-- WHERE is_staffed = 1
ORDER BY coalesce(counter_id,0) desc,shift_id, staff_id
LIMIT 10000

------

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_106_copy_of_final_output` as
SELECT *
FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer`
;

CREATE OR REPLACE TABLE `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer` as
SELECT
    * except(counter_id)
  , case
      when counter_id > 1280 then counter_id + 1
      when counter_id = 1280 and grand_total = 1120 then counter_id + 1
      else counter_id
    end as counter_id
FROM `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer`
-- WHERE is_staffed = 1 and counter_id between 1275 and 1285
-- ORDER BY coalesce(counter_id,999999) desc,shift_id, staff_id
-- LIMIT 10000
;
*/
```

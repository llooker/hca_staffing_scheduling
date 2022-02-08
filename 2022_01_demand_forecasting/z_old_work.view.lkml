# ### Raw Data

# explore: hourly_census_2_hosp_pre {
#   hidden: yes
# }

# explore: hourly_census_2_hosp {
#   join: v_24_hours_28_forecast_2021_12_26_results_90_CI {
#     relationship: many_to_one
#     sql_on:
#         ${hourly_census_2_hosp.model_key_a_24} = ${v_24_hours_28_forecast_2021_12_26_results_90_CI.key}
#     AND ${hourly_census_2_hosp.census_date} = ${v_24_hours_28_forecast_2021_12_26_results_90_CI.time_series_timestamp}
#     ;;
#   }
# }

view: hourly_census_2_hosp {
  sql_table_name:
  (
              SELECT 'Henrico' as hospital_name, * FROM `hca-data-sandbox.staffing_scheduling.demand_forecasting_raw_henrico`
    UNION ALL SELECT 'Lake Nona' as hospital_name, * FROM `hca-data-sandbox.staffing_scheduling.demand_forecasting_raw_lakenona`
  )
  ;;
#######################
### Original Dimensions
#######################

  dimension_group: census {
    type: time
    timeframes: [
      raw,
      time,
      hour_of_day,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.census_time ;;
  }

  dimension: count_patients {
    type: number
    sql: ${TABLE}.COUNT_PATIENTS ;;
  }

  dimension: hospital_name {
    type: string
    sql: ${TABLE}.hospital_name ;;
  }

  dimension: int64_field_0 {
    type: number
    sql: ${TABLE}.int64_field_0 ;;
  }

#######################
### Derived Dimensions
#######################

### Break out into hour bands

  dimension: hour_period_a_24 {
    type: string
    sql: 'A - 0-24' ;;
  }

  dimension: hour_period_b_12 {
    type: string
    sql:
      case
        when ${census_hour_of_day} BETWEEN 7 and 18 THEN 'A - 7 am - 7 pm'
        else 'B - 7 pm - 7 am'
      end ;;
  }

  dimension: hour_period_c_6 {
    type: string
    sql:
      case
        when ${census_hour_of_day} BETWEEN 7 and 12 THEN 'A - 7 am - 1 pm'
        when ${census_hour_of_day} BETWEEN 13 and 18 THEN 'B - 1 pm - 7 pm'
        when ${census_hour_of_day} > 18 or ${census_hour_of_day} < 1 THEN 'C - 7 pm - 1 am'
        else 'D - 1 am - 7 am'
      end ;;
  }

  dimension: hour_period_d_4 {
    type: string
    sql:
      case
        when ${census_hour_of_day} BETWEEN 7 and 10 THEN 'A - 7 am - 11 am'
        when ${census_hour_of_day} BETWEEN 11 and 14 THEN 'B - 11 am - 3 pm'
        when ${census_hour_of_day} BETWEEN 15 and 18 THEN 'C - 3 pm - 7 pm'
        when ${census_hour_of_day} BETWEEN 19 and 22 THEN 'D - 7 pm - 11 pm'
        when ${census_hour_of_day} > 22 or ${census_hour_of_day} < 3 THEN 'E - 11 pm - 3 am'
        else 'F - 3 am - 7 am'
      end ;;
  }

  dimension: hour_period_e_2 {
    type: string
    sql:
      case
        when ${census_hour_of_day} BETWEEN 7 and 8 THEN 'A - 7 am - 9 am'
        when ${census_hour_of_day} BETWEEN 9 and 10 THEN 'B - 9 am - 11 am'
        when ${census_hour_of_day} BETWEEN 11 and 12 THEN 'C - 11 am - 1 pm'
        when ${census_hour_of_day} BETWEEN 13 and 14 THEN 'D - 1 pm - 3 pm'
        when ${census_hour_of_day} BETWEEN 15 and 16 THEN 'E - 3 pm - 5 pm'
        when ${census_hour_of_day} BETWEEN 17 and 18 THEN 'F - 5 pm - 7 pm'
        when ${census_hour_of_day} BETWEEN 19 and 20 THEN 'G - 7 pm - 9 pm'
        when ${census_hour_of_day} BETWEEN 21 and 22 THEN 'H - 9 pm - 11 pm'
        when ${census_hour_of_day} > 22 or ${census_hour_of_day} < 1 THEN 'I - 11 pm - 1 am'
        when ${census_hour_of_day} BETWEEN 1 and 2 THEN 'J - 1 am - 3 am'
        when ${census_hour_of_day} BETWEEN 3 and 4 THEN 'K - 3 am - 5 am'
        else 'L - 5 am - 7 am'
      end ;;
  }

### Create a model key that combines hour bands + hospital

  dimension: model_key_a_24 {
    type: string
    sql: ${hospital_name} || ' | ' || ${hour_period_a_24} ;;
  }

  dimension: model_key_b_12 {
    type: string
    sql: ${hospital_name} || ' | ' || ${hour_period_b_12} ;;
  }

  dimension: model_key_c_6 {
    type: string
    sql: ${hospital_name} || ' | ' || ${hour_period_c_6} ;;
  }

  dimension: model_key_d_4 {
    type: string
    sql: ${hospital_name} || ' | ' || ${hour_period_d_4} ;;
  }

  dimension: model_key_e_2 {
    type: string
    sql: ${hospital_name} || ' | ' || ${hour_period_e_2} ;;
  }

### Handle 4 date periods

  parameter: days_before_prediction {
    type: number
    default_value: "28"
  }

  parameter: forecast_length {
    type: number
    default_value: "28"
  }

  parameter: start_date_prediction {
    type: date
    default_value: "2021-12-26"
  }

  dimension: is_before_timeframe {
    type: yesno
    sql: ${census_date} <= DATE_ADD(cast({% parameter start_date_prediction %} as date), interval {% parameter days_before_prediction %}*-1 day)  ;;
  }

  dimension: is_during_prediction_window {
    type: yesno
    sql:
        ${census_date} >= cast({% parameter start_date_prediction %} as date)
    AND ${census_date} < DATE_ADD(cast({% parameter start_date_prediction %} as date), interval {% parameter forecast_length %} day) ;;
  }

#######################
### Measures
#######################

  measure: count {
    type: count
    drill_fields: []
  }

  measure: total_patients {
    type: sum
    sql: ${count_patients} ;;
  }

  measure: max_value {
    type: max
    sql: ${count_patients} ;;
  }
}

# view: hourly_census_2_hosp_pre {
#   derived_table: {
#     datagroup_trigger: once_daily
#     publish_as_db_view: yes
#     sql:
#                 SELECT 'Henrico' as hospital_name, * FROM `hca-data-sandbox.staffing_scheduling.demand_forecasting_raw_henrico`
#       UNION ALL SELECT 'Lake Nona' as hospital_name, * FROM `hca-data-sandbox.staffing_scheduling.demand_forecasting_raw_lakenona`
#     ;;
#   }

#   dimension: count_patients {}
# }


# parameter: timeframe2 {
#   type: date
#   default_value: "2021-08-22"
# }

# parameter: timeframe3 {
#   type: date
#   default_value: "2021-10-24"
# }

# parameter: timeframe4 {
#   type: date
#   default_value: "2021-12-26"
# }

# dimension: is_before_timeframe2 {
#   type: yesno
#   sql: DATE_DIFF(cast({% parameter timeframe2 %} as date), ${census_date}, day) >= {% parameter prediction_days_prior %} ;;
# }

# dimension: is_before_timeframe3 {
#   type: yesno
#   sql: DATE_DIFF(cast({% parameter timeframe3 %} as date), ${census_date}, day) >= {% parameter prediction_days_prior %} ;;
# }

# dimension: is_before_timeframe4 {
#   type: yesno
#   sql: DATE_DIFF(cast({% parameter timeframe4 %} as date), ${census_date}, day) >= {% parameter prediction_days_prior %} ;;
# }



# ########################
# ### 1. Generate Data
# ########################

# # Check - title
# view: v_24_hours_28_forecast_2021_12_26_data {
#   extends: [template_data]
#   derived_table: {
#     publish_as_db_view: yes
#     explore_source: hourly_census_2_hosp {
#       column: census_date {}
#       column: max_value {}
#       # Check - key
#       column: key { field: hourly_census_2_hosp.model_key_a_24 }
#       filters: {
#         field: hourly_census_2_hosp.is_before_timeframe
#         value: "Yes"
#       }
#       # Check - prediction days prior
#       filters: {
#         field: hourly_census_2_hosp.days_before_prediction
#         value: "28"
#       }
#       # Check - start prediction
#       filters: {
#         field: hourly_census_2_hosp.start_date_prediction
#         value: "2021-12-26"
#       }
#     }
#   }
#   dimension: x {}
# }

# ########################
# ### 2. Build ARIMA Model
# ########################

# # Check - title
# view: v_24_hours_28_forecast_2021_12_26_model {
#   derived_table: {
#     datagroup_trigger: once_daily
#     # Check - SQL_TABLE_NAME
#     sql_create:
#       CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
#       OPTIONS(
#           model_type='ARIMA_plus'
#         , TIME_SERIES_TIMESTAMP_COL = 'census_date'
#         , TIME_SERIES_DATA_COL = 'max_value'
#         , TIME_SERIES_ID_COL = 'key'
#         ) AS
#       SELECT *
#       FROM ${v_24_hours_28_forecast_2021_12_26_data.SQL_TABLE_NAME};;
#   }
#   dimension: x {}
# }

# ########################
# ### 3. ARIMA Forecast Results
# ########################

# # Check - title
# view: v_24_hours_28_forecast_2021_12_26_results_90_CI {
#   extends: [template_results]
#   derived_table: {
#     # Check - SQL_TABLE_NAME, confidence level
#     sql: SELECT * FROM ml.EXPLAIN_FORECAST(
#           MODEL ${v_24_hours_28_forecast_2021_12_26_model.SQL_TABLE_NAME},
#         STRUCT(200 as horizon, 0.9 as confidence_level))
#     ;;
#   }
# }

# ########################
# ### 4. Combine results with actual model
# ########################

# # Check - title
# view: v_24_hours_28_forecast_2021_12_26_results_90_CI_combined {
#   extends: [template_results_combined]
#   derived_table: {
#     # datagroup_trigger: once_daily
#     explore_source: hourly_census_2_hosp {
#       column: census_date {}
#       column: actual { field: hourly_census_2_hosp.max_value }
#       # Check - SQL_TABLE_NAME, column
#       column: prediction { field: v_24_hours_28_forecast_2021_12_26_results_90_CI.prediction_interval_upper_bound }
#       filters: {
#         field: hourly_census_2_hosp.is_during_prediction_window
#         value: "Yes"
#       }
#       # Check - length_forecast
#       filters: {
#         field: hourly_census_2_hosp.forecast_length
#         value: "28"
#       }
#       # Check - start_date
#       filters: {
#         field: hourly_census_2_hosp.start_date_prediction
#         value: "2021/12/26"
#       }
#       # Check - hospital
#       filters: {
#         field: hourly_census_2_hosp.hospital_name
#         value: "Henrico"
#       }
#     }
#   }
#   dimension: model_forecast_days_in_advance {
#     type: number
#     sql: 28 ;;
#   }
#   dimension: model_forecast_length {
#     type: number
#     sql: 28 ;;
#   }
#   dimension: model_start_date {
#     type: date
#     sql: '2021-12-26' ;;
#   }
#   dimension: model_type {
#     type: string
#     sql: 'ARIMA_plus' ;;
#   }
#   dimension: model_hour_bands {
#     type: number
#     sql: 24 ;;
#   }
#   dimension: model_ci_max {
#     type: number
#     sql: 90 ;;
#   }
# }

# ########################
# ### 5. Build model Summary
# ########################

# view: v_24_hours_28_forecast_2021_12_26_results_90_CI_summary {
#   derived_table: {
#     datagroup_trigger: once_daily
#     explore_source: v_24_hours_28_forecast_2021_12_26_results_90_CI_combined {
#       column: model_ci_max {}
#       column: model_forecast_days_in_advance {}
#       column: model_forecast_length {}
#       column: model_hour_bands {}
#       column: model_start_date {}
#       column: model_type {}
#       column: average_daily_score {}
#       column: total_score {}
#       column: number_days_cat_1 {}
#       column: number_days_cat_2 {}
#       column: number_days_cat_3 {}
#       column: number_days_cat_4 {}
#       column: number_days_cat_5 {}
#       column: number_total_days {}
#     }
#   }
# }

# ########################
# ### 6. Combine into final summary
# ########################

# view: final_summary {
#   extends: [template_results_summary]
#   derived_table: {
#     sql:
#       SELECT * FROM ${v_24_hours_28_forecast_2021_12_26_results_90_CI_summary.SQL_TABLE_NAME}

#     ;;
#   }
# }

# explore: v_24_hours_28_forecast_2021_12_26_data {}
# explore: v_24_hours_28_forecast_2021_12_26_results_90_CI_combined {}
# explore: final_summary {}

# ########################
# ### Templates
# ########################

# view: template_data {
#   dimension: census_date {
#     type: date
#   }
#   dimension: max_value {
#     type: number
#   }
#   dimension: key {}
# }

# view: template_results {
#   dimension: pk {
#     primary_key: yes
#     type: string
#     sql: ${key} || ' | ' || ${time_series_timestamp} ;;
#   }
#   dimension: key { type: string }
#   dimension: time_series_timestamp { type: date sql: cast(${TABLE}.time_series_timestamp as date) ;; }
#   dimension: time_series_type { type: string }
#   dimension: time_series_data { type: number }
#   dimension: time_series_adjusted_data { type: number }
#   dimension: standard_error { type: number }
#   dimension: confidence_level { type: number }
#   dimension: prediction_interval_lower_bound { type: number }
#   dimension: prediction_interval_upper_bound { type: number }
#   dimension: trend { type: number }
#   dimension: seasonal_period_yearly { type: number }
#   dimension: seasonal_period_quarterly { type: number }
#   dimension: seasonal_period_monthly { type: number }
#   dimension: seasonal_period_weekly { type: number }
#   dimension: seasonal_period_daily { type: number }
#   dimension: holiday_effect { type: number }
#   dimension: spikes_and_dips { type: number }
#   dimension: step_changes { type: number }
# }

# view: template_results_combined {
#   dimension: census_date {
#     type: date
#   }
#   dimension: actual {
#     type: number
#     value_format_name: decimal_1
#   }
#   dimension: prediction {
#     type: number
#     value_format_name: decimal_1
#   }
#   dimension: difference_abs {
#     type: number
#     sql: ${actual} - ${prediction} ;;
#     value_format_name: decimal_1
#   }
#   dimension: difference_perc {
#     type: number
#     sql: ${difference_abs} / nullif(${actual},0) ;;
#     value_format_name: percent_1
#   }
#   dimension: score_buckets {
#     type: string
#     sql:
#       case
#         when ${difference_perc} > 0.9 or ${difference_perc} < -0.5 then '5 - Black'
#         when ${difference_perc} > 0.7 or ${difference_perc} < -0.4 then '4 - Red'
#         when ${difference_perc} > 0.5 or ${difference_perc} < -0.3 then '3 - Orange'
#         when ${difference_perc} > 0.3 or ${difference_perc} < -0.2 then '2 - Yellow'
#         else '1 - Green'
#       end
#     ;;
#   }
#   dimension: score_number {
#     type: number
#     sql:
#       case
#         when ${score_buckets} like '%5%' then -1000
#         when ${score_buckets} like '%4%' then -500
#         when ${score_buckets} like '%3%' then -100
#         when ${score_buckets} like '%2%' then -10
#         else 0
#       end
#     ;;
#   }
#   measure: total_score {
#     type: sum
#     sql: ${score_number} ;;
#   }
#   measure: average_daily_score {
#     type: number
#     sql: ${total_score} / nullif(${number_total_days},0) ;;
#   }
#   measure: number_days_cat_5 {
#     type: count_distinct
#     sql: ${census_date} ;;
#     filters: [score_buckets: "5%"]
#   }
#   measure: number_days_cat_4 {
#     type: count_distinct
#     sql: ${census_date} ;;
#     filters: [score_buckets: "4%"]
#   }
#   measure: number_days_cat_3 {
#     type: count_distinct
#     sql: ${census_date} ;;
#     filters: [score_buckets: "3%"]
#   }
#   measure: number_days_cat_2 {
#     type: count_distinct
#     sql: ${census_date} ;;
#     filters: [score_buckets: "2%"]
#   }
#   measure: number_days_cat_1 {
#     type: count_distinct
#     sql: ${census_date} ;;
#     filters: [score_buckets: "1%"]
#   }
#   measure: number_days_cat_5_or_4 {
#     type: count_distinct
#     sql: ${census_date} ;;
#     filters: [score_buckets: "5%, 4%"]
#   }
#   measure: number_total_days {
#     type: count_distinct
#     sql: ${census_date} ;;
#   }
# }

# view: template_results_summary {
#   dimension: model_ci_max {
#     type: number
#   }
#   dimension: model_forecast_days_in_advance {
#     type: number
#   }
#   dimension: model_forecast_length {
#     type: number
#   }
#   dimension: model_hour_bands {
#     type: number
#   }
#   dimension: model_start_date {
#     type: date
#   }
#   dimension: model_type {}
#   dimension: average_daily_score {
#     value_format: "#,##0.0"
#     type: number
#   }
#   dimension: total_score {
#     type: number
#   }
#   dimension: number_days_cat_1 {
#     type: number
#   }
#   dimension: number_days_cat_2 {
#     type: number
#   }
#   dimension: number_days_cat_3 {
#     type: number
#   }
#   dimension: number_days_cat_4 {
#     type: number
#   }
#   dimension: number_days_cat_5 {
#     type: number
#   }
#   dimension: number_total_days {
#     type: number
#   }
#   measure: avg_daily_score {
#     type: average
#     sql: ${average_daily_score};;
#     value_format_name: decimal_1
#   }
#   measure: total_number_days_cat_1 {
#     type: sum
#   }
#   measure: total_number_days_cat_2 {
#     type: sum
#   }
#   measure: total_number_days_cat_3 {
#     type: sum
#   }
#   measure: total_number_days_cat_4 {
#     type: sum
#   }
#   measure: total_number_days_cat_5 {
#     type: sum
#   }
#   measure: total_number_total_days {
#     type: sum
#   }
#   measure: percent_cat_5 {
#     type: number
#     sql: ${total_number_days_cat_5} / nullif(${total_number_total_days},0) ;;
#     value_format_name: percent_1
#   }
#   measure: percent_cat_4 {
#     type: number
#     sql: ${total_number_days_cat_4} / nullif(${total_number_total_days},0) ;;
#     value_format_name: percent_1
#   }
#   measure: percent_cat_3 {
#     type: number
#     sql: ${total_number_days_cat_3} / nullif(${total_number_total_days},0) ;;
#     value_format_name: percent_1
#   }
#   measure: percent_cat_2 {
#     type: number
#     sql: ${total_number_days_cat_2} / nullif(${total_number_total_days},0) ;;
#     value_format_name: percent_1
#   }
#   measure: percent_cat_1 {
#     type: number
#     sql: ${total_number_days_cat_1} / nullif(${total_number_total_days},0) ;;
#     value_format_name: percent_1
#   }
# }

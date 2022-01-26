view: template_data {
  dimension: census_date {
    type: date
  }
  dimension: max_value {
    type: number
  }
  dimension: key {}
}

view: template_results {
  dimension: pk {
    primary_key: yes
    type: string
    sql: ${key} || ' | ' || ${time_series_timestamp} ;;
  }
  dimension: key { type: string }
  dimension: time_series_timestamp { type: date sql: cast(${TABLE}.time_series_timestamp as date) ;; }
  dimension: time_series_type { type: string }
  dimension: time_series_data { type: number }
  dimension: time_series_adjusted_data { type: number }
  dimension: standard_error { type: number }
  dimension: confidence_level { type: number }
  dimension: prediction_interval_lower_bound { type: number }
  dimension: prediction_interval_upper_bound { type: number }
  dimension: trend { type: number }
  dimension: seasonal_period_yearly { type: number }
  dimension: seasonal_period_quarterly { type: number }
  dimension: seasonal_period_monthly { type: number }
  dimension: seasonal_period_weekly { type: number }
  dimension: seasonal_period_daily { type: number }
  dimension: holiday_effect { type: number }
  dimension: spikes_and_dips { type: number }
  dimension: step_changes { type: number }
}

view: template_results_combined {
  dimension: census_date {
    type: date
  }
  dimension: actual {
    type: number
    value_format_name: decimal_1
  }
  dimension: prediction {
    type: number
    value_format_name: decimal_1
  }
  dimension: difference_abs {
    type: number
    sql: ${actual} - ${prediction} ;;
    value_format_name: decimal_1
  }
  dimension: difference_perc {
    type: number
    sql: ${difference_abs} / nullif(${actual},0) ;;
    value_format_name: percent_1
  }
  dimension: score_buckets {
    type: string
    sql:
      case
        when ${difference_perc} > 0.9 or ${difference_perc} < -0.5 then '5 - Black'
        when ${difference_perc} > 0.7 or ${difference_perc} < -0.4 then '4 - Red'
        when ${difference_perc} > 0.5 or ${difference_perc} < -0.3 then '3 - Orange'
        when ${difference_perc} > 0.3 or ${difference_perc} < -0.2 then '2 - Yellow'
        else '1 - Green'
      end
    ;;
  }
  dimension: score_number {
    type: number
    sql:
      case
        when ${score_buckets} like '%5%' then -1000
        when ${score_buckets} like '%4%' then -500
        when ${score_buckets} like '%3%' then -100
        when ${score_buckets} like '%2%' then -10
        else 0
      end
    ;;
  }
  measure: total_score {
    type: sum
    sql: ${score_number} ;;
  }
  measure: average_daily_score {
    type: number
    sql: ${total_score} / nullif(${number_total_days},0) ;;
  }
  measure: number_days_cat_5 {
    type: count_distinct
    sql: ${census_date} ;;
    filters: [score_buckets: "5%"]
  }
  measure: number_days_cat_4 {
    type: count_distinct
    sql: ${census_date} ;;
    filters: [score_buckets: "4%"]
  }
  measure: number_days_cat_3 {
    type: count_distinct
    sql: ${census_date} ;;
    filters: [score_buckets: "3%"]
  }
  measure: number_days_cat_2 {
    type: count_distinct
    sql: ${census_date} ;;
    filters: [score_buckets: "2%"]
  }
  measure: number_days_cat_1 {
    type: count_distinct
    sql: ${census_date} ;;
    filters: [score_buckets: "1%"]
  }
  measure: number_days_cat_5_or_4 {
    type: count_distinct
    sql: ${census_date} ;;
    filters: [score_buckets: "5%, 4%"]
  }
  measure: number_total_days {
    type: count_distinct
    sql: ${census_date} ;;
  }
}

view: template_results_summary {
  dimension: model_ci_max {
    type: number
  }
  dimension: model_forecast_days_in_advance {
    type: number
  }
  dimension: model_forecast_length {
    type: number
  }
  dimension: model_hour_bands {
    type: number
  }
  dimension: model_start_date {
    type: date
  }
  dimension: model_type {}
  dimension: average_daily_score {
    value_format: "#,##0.0"
    type: number
  }
  dimension: total_score {
    type: number
  }
  dimension: number_days_cat_1 {
    type: number
  }
  dimension: number_days_cat_2 {
    type: number
  }
  dimension: number_days_cat_3 {
    type: number
  }
  dimension: number_days_cat_4 {
    type: number
  }
  dimension: number_days_cat_5 {
    type: number
  }
  dimension: number_total_days {
    type: number
  }
  measure: avg_daily_score {
    type: average
    sql: ${average_daily_score};;
    value_format_name: decimal_1
  }
  measure: total_number_days_cat_1 {
    type: sum
  }
  measure: total_number_days_cat_2 {
    type: sum
  }
  measure: total_number_days_cat_3 {
    type: sum
  }
  measure: total_number_days_cat_4 {
    type: sum
  }
  measure: total_number_days_cat_5 {
    type: sum
  }
  measure: total_number_total_days {
    type: sum
  }
  measure: percent_cat_5 {
    type: number
    sql: ${total_number_days_cat_5} / nullif(${total_number_total_days},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_4 {
    type: number
    sql: ${total_number_days_cat_4} / nullif(${total_number_total_days},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_3 {
    type: number
    sql: ${total_number_days_cat_3} / nullif(${total_number_total_days},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_2 {
    type: number
    sql: ${total_number_days_cat_2} / nullif(${total_number_total_days},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_1 {
    type: number
    sql: ${total_number_days_cat_1} / nullif(${total_number_total_days},0) ;;
    value_format_name: percent_1
  }
}

view: v_24_hours_28_forecast_2021_12_26_data {
  extends: [template_data]
  derived_table: {
    publish_as_db_view: yes
    explore_source: hourly_census_2_hosp {
      column: census_date {}
      column: max_value {}
      column: key { field: hourly_census_2_hosp.model_key_a_24 }
      filters: {
        field: hourly_census_2_hosp.is_before_timeframe
        value: "Yes"
      }
      filters: {
        field: hourly_census_2_hosp.prediction_days_prior
        value: "28"
      }
      filters: {
        field: hourly_census_2_hosp.timeframe
        value: "2021-12-26"
      }
    }
  }
  dimension: x {}
}

view: v_24_hours_28_forecast_2021_12_26_model {
  derived_table: {
    datagroup_trigger: once_daily
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(
          model_type='ARIMA_plus'
        , TIME_SERIES_TIMESTAMP_COL = 'census_date'
        , TIME_SERIES_DATA_COL = 'max_value'
        , TIME_SERIES_ID_COL = 'key'
        ) AS
      SELECT *
      FROM ${v_24_hours_28_forecast_2021_12_26_data.SQL_TABLE_NAME};;
  }
  dimension: x {}
}

view: v_24_hours_28_forecast_2021_12_26_results_90_CI {
  extends: [template_results]
  derived_table: {
    sql: SELECT * FROM ml.EXPLAIN_FORECAST(
          MODEL ${v_24_hours_28_forecast_2021_12_26_model.SQL_TABLE_NAME},
         STRUCT(200 as horizon, 0.9 as confidence_level))
    ;;
  }
}

view: v_24_hours_28_forecast_2021_12_26_results_90_CI_combined {
  extends: [template_results_combined]
  derived_table: {
    datagroup_trigger: once_daily
    explore_source: hourly_census_2_hosp {
      column: census_date {}
      column: actual { field: hourly_census_2_hosp.max_value }
      column: prediction { field: v_24_hours_28_forecast_2021_12_26_results_90_CI.prediction_interval_upper_bound }
      filters: {
        field: hourly_census_2_hosp.is_during_prediction_window
        value: "Yes"
      }
      filters: {
        field: hourly_census_2_hosp.forecast_length
        value: "28"
      }
      filters: {
        field: hourly_census_2_hosp.timeframe
        value: "2021/12/26"
      }
      filters: {
        field: hourly_census_2_hosp.hospital_name
        value: "Henrico"
      }
    }
  }
  dimension: model_forecast_days_in_advance {
    type: number
    sql: 28 ;;
  }
  dimension: model_forecast_length {
    type: number
    sql: 28 ;;
  }
  dimension: model_start_date {
    type: date
    sql: '2021-12-26' ;;
  }
  dimension: model_type {
    type: string
    sql: 'ARIMA_plus' ;;
  }
  dimension: model_hour_bands {
    type: number
    sql: 24 ;;
  }
  dimension: model_ci_max {
    type: number
    sql: 90 ;;
  }
}

view: v_24_hours_28_forecast_2021_12_26_results_90_CI_summary {
  derived_table: {
    datagroup_trigger: once_daily
    explore_source: v_24_hours_28_forecast_2021_12_26_results_90_CI_combined {
      column: model_ci_max {}
      column: model_forecast_days_in_advance {}
      column: model_forecast_length {}
      column: model_hour_bands {}
      column: model_start_date {}
      column: model_type {}
      column: average_daily_score {}
      column: total_score {}
      column: number_days_cat_1 {}
      column: number_days_cat_2 {}
      column: number_days_cat_3 {}
      column: number_days_cat_4 {}
      column: number_days_cat_5 {}
      column: number_total_days {}
    }
  }
}

view: final_summary {
  extends: [template_results_summary]
  derived_table: {
    sql:
      SELECT * FROM ${v_24_hours_28_forecast_2021_12_26_results_90_CI_summary.SQL_TABLE_NAME}

    ;;
  }
}

explore: v_24_hours_28_forecast_2021_12_26_results_90_CI_combined {}
explore: final_summary {}

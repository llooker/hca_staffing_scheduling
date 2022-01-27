view: demand_forecasting_5_summary_results {
  sql_table_name: `hca-data-sandbox.staffing_scheduling.demand_forecasting_5_summary_results`
    ;;

  dimension: counter_id {
    type: number
    sql: ${TABLE}.counter_id ;;
  }

  dimension: days_prior_to_forecast {
    type: number
    sql: ${TABLE}.days_prior_to_forecast ;;
  }

  dimension: hour_band {
    type: number
    sql: ${TABLE}.hour_band ;;
  }

  dimension: model_outputs {
    hidden: yes
    sql: ${TABLE}.model_outputs ;;
  }

  dimension: model_type {
    type: string
    sql: ${TABLE}.model_type ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.start_date ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

view: demand_forecasting_5_summary_results__model_outputs {
  dimension: actual {
    type: number
    sql: ${TABLE}.actual ;;
  }

  dimension_group: census {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.census_date ;;
  }

  dimension: days_since_prediction {
    type: number
    sql: ${TABLE}.days_since_prediction ;;
  }

  dimension: expected {
    type: number
    sql: ${TABLE}.expected ;;
  }

  dimension: expected_upper_bound_ci_50 {
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_50 ;;
  }

  dimension: expected_upper_bound_ci_60 {
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_60 ;;
  }

  dimension: expected_upper_bound_ci_70 {
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_70 ;;
  }

  dimension: expected_upper_bound_ci_80 {
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_80 ;;
  }

  dimension: expected_upper_bound_ci_90 {
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_90 ;;
  }

  dimension: expected_upper_bound_ci_99 {
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_99 ;;
  }

  dimension: hospital {
    type: string
    sql: ${TABLE}.hospital ;;
  }

  dimension: hour_of_day {
    type: string
    sql: ${TABLE}.hour_of_day ;;
  }

  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
  }
}

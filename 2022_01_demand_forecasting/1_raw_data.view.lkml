view: hourly_census_2_hosp {
  sql_table_name: `hca-data-sandbox.looker_scratch2.A3_f1_f2_staffing_scheduling_hourly_census_2_hosp_pre`
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

  parameter: prediction_days_prior {
    type: number
    default_value: "28"
  }

  parameter: forecast_length {
    type: number
    default_value: "28"
  }

  parameter: timeframe {
    type: date
    default_value: "2021-12-26"
  }

  dimension: is_before_timeframe {
    type: yesno
    sql: ${census_date} <= DATE_ADD(cast({% parameter timeframe %} as date), interval {% parameter prediction_days_prior %}*-1 day)  ;;
  }

  dimension: is_during_prediction_window {
    type: yesno
    sql:
        ${census_date} >= cast({% parameter timeframe %} as date)
    AND ${census_date} < DATE_ADD(cast({% parameter timeframe %} as date), interval {% parameter forecast_length %} day) ;;
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

view: hourly_census_2_hosp_pre {
  derived_table: {
    datagroup_trigger: once_daily
    publish_as_db_view: yes
    sql:
                SELECT 'Henrico' as hospital_name, * FROM `hca-data-sandbox.staffing_scheduling.demand_forecasting_raw_henrico`
      UNION ALL SELECT 'Lake Nona' as hospital_name, * FROM `hca-data-sandbox.staffing_scheduling.demand_forecasting_raw_lakenona`
    ;;
  }

  dimension: count_patients {}
}


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

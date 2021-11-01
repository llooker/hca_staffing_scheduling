view: staffing_volume_predictions_1_load_raw_data {
  sql_table_name: `staffing_scheduling.staffing_volume_predictions_1_load_raw_data`
    ;;

######################
### Original Dimensions
######################

  dimension: doctor_id {
    type: string
    sql: ${TABLE}.doctor_id ;;
  }

  dimension: facility_id {
    type: string
    sql: ${TABLE}.facility_id ;;
  }

  dimension: nurse_id {
    type: string
    sql: ${TABLE}.nurse_id ;;
  }

  dimension_group: operation {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      hour_of_day,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.operation_time ;;
  }

######################
### Derived Dimensions
######################

  dimension: shift {
    type: string
    sql:
      case
        when ${operation_hour_of_day} BETWEEN 6 and 14 then '1 - Morning'
        when ${operation_hour_of_day} BETWEEN 14 and 22 then '2 - Evening'
        else '3 - Graveyard'
      end
    ;;
  }

######################
### Measures
######################

  measure: volume {
    type: count
    drill_fields: []
  }
}

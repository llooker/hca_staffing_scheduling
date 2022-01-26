view: demand_forecasting_raw_lakenona {
  sql_table_name: `hca-data-sandbox.staffing_scheduling.demand_forecasting_raw_lakenona`
    ;;

  dimension_group: census {
    type: time
    timeframes: [
      raw,
      time,
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

  dimension: int64_field_0 {
    type: number
    sql: ${TABLE}.int64_field_0 ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

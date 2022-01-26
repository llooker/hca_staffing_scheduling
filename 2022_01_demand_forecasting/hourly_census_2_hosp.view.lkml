view: hourly_census_2_hosp {
  sql_table_name:
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

  dimension: hospital_name {
    type: number
    sql: ${TABLE}.int64_field_0 ;;
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

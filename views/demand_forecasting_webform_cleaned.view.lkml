view: demand_forecasting_webform_cleaned {
  sql_table_name: `hca-data-sandbox.staffing_scheduling.demand_forecasting_webform_cleaned`
    ;;

  dimension: date_pk {
    primary_key: yes
    type: string
    sql: ${date_date} ;;
  }

  dimension_group: date {
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
    sql: ${TABLE}.date ;;
  }

  dimension: points0 {
    type: number
    sql: ${TABLE}.points0 ;;
  }

  dimension: points1 {
    type: number
    sql: ${TABLE}.points1 ;;
  }

  dimension: points14 {
    type: number
    sql: ${TABLE}.points14 ;;
  }

  dimension: points21 {
    type: number
    sql: ${TABLE}.points21 ;;
  }

  dimension: points3 {
    type: number
    sql: ${TABLE}.points3 ;;
  }

  dimension: points7 {
    type: number
    sql: ${TABLE}.points7 ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

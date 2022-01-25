view: count_pre_registrations_by_date {
  sql_table_name: `hca-cti-ds-hackathon.f1_f2_staffing_scheduling.count_pre_registrations_by_date`
    ;;

  dimension: pk {
    type: string
    primary_key: yes
    sql: ${coid} || ' | ' || ${pre_registration_raw} ;;
  }

  dimension: coid {
    type: number
    value_format_name: id
    sql: ${TABLE}.COID ;;
  }

  dimension: count_pre_registrations {
    type: number
    sql: ${TABLE}.count_pre_registrations ;;
  }

  dimension: facility {
    type: string
    sql: ${TABLE}.facility ;;
  }

  dimension: first_location {
    type: string
    sql: ${TABLE}.first_location ;;
  }

  dimension_group: pre_registration {
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
    sql: ${TABLE}.pre_registration_date ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: total_pre_registrations {
    type: sum
    sql: ${count_pre_registrations} ;;
  }

  measure: percent_pre_registrations_total_volume {
    type: number
    sql: ${total_pre_registrations} / nullif(${hourly_census.volume},0) ;;
    value_format_name: percent_1
  }
}

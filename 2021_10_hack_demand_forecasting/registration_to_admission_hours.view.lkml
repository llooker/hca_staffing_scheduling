view: registration_to_admission_hours {
  sql_table_name: `hca-cti-ds-hackathon.f1_f2_staffing_scheduling.registration_to_admission_hours`
    ;;

  dimension: coid {
    type: number
    value_format_name: id
    sql: ${TABLE}.COID ;;
  }

  dimension: facility {
    type: string
    sql: ${TABLE}.facility ;;
  }

  dimension: first_location {
    type: string
    sql: ${TABLE}.first_location ;;
  }

  dimension: hours_registration_to_admission {
    type: string
    sql: ${TABLE}.hours_registration_to_admission ;;
  }

  dimension: days_registration_to_admission_number {
    type: number
    sql: safe_cast(${hours_registration_to_admission} as float64) / 24 ;;
  }

  dimension: days_registration_to_admission_number_force_positive {
    type: number
    sql: case when ${days_registration_to_admission_number} < 0 then 0 else ${days_registration_to_admission_number} end ;;
  }

  measure: days_1_min {
    type: min
    sql: ${days_registration_to_admission_number_force_positive} ;;
    value_format_name: decimal_1
  }

  measure: days_2_25 {
    type: percentile
    percentile: 25
    sql: ${days_registration_to_admission_number_force_positive} ;;
    value_format_name: decimal_1
  }

  measure: days_3_median {
    type: median
    sql: ${days_registration_to_admission_number_force_positive} ;;
    value_format_name: decimal_1
  }

  measure: days_4_75 {
    type: percentile
    percentile: 75
    sql: ${days_registration_to_admission_number_force_positive} ;;
    value_format_name: decimal_1
  }

  measure: days_5_max {
    type: max
    sql: ${days_registration_to_admission_number_force_positive} ;;
    value_format_name: decimal_1
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

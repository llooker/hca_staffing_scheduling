view: volume_by_facility_by_shift_by_day {
  derived_table: {
    datagroup_trigger: new_data
    explore_source: staffing_volume_predictions_1_load_raw_data {
      column: coid {}
      column: coid_department {}
      column: census_date {}
      column: shift {}
      column: volume {}
      column: prediction_group {}
      derived_column: volume_6_week_ago_same_day_of_week   { sql: LAG(volume, 42) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC) ;; }
      derived_column: volume_7_week_ago_same_day_of_week   { sql: LAG(volume, 49) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC) ;; }
      derived_column: volume_8_week_ago_same_day_of_week   { sql: LAG(volume, 56) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC) ;; }
      derived_column: volume_9_week_ago_same_day_of_week   { sql: LAG(volume, 63) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC) ;; }
      # derived_column: volume_52_week_ago_same_day_of_week  { sql: LAG(volume, 364) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC) ;; }
      # derived_column: volume_53_week_ago_same_day_of_week  { sql: LAG(volume, 371) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC) ;; }
      # derived_column: volume_104_week_ago_same_day_of_week { sql: LAG(volume, 728) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC) ;; }
      # derived_column: volume_105_week_ago_same_day_of_week { sql: LAG(volume, 735) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC) ;; }
      derived_column: avg_volume_6_weeks_ago   { sql: AVG(volume) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC ROWS BETWEEN 48 PRECEDING AND 42 PRECEDING ) ;; }
      derived_column: avg_volume_7_weeks_ago   { sql: AVG(volume) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC ROWS BETWEEN 55 PRECEDING AND 49 PRECEDING ) ;; }
      derived_column: avg_volume_8_weeks_ago   { sql: AVG(volume) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC ROWS BETWEEN 62 PRECEDING AND 56 PRECEDING ) ;; }
      derived_column: avg_volume_9_weeks_ago   { sql: AVG(volume) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC ROWS BETWEEN 69 PRECEDING AND 63 PRECEDING ) ;; }
      # derived_column: avg_volume_52_weeks_ago  { sql: AVG(volume) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC ROWS BETWEEN 370 PRECEDING AND 364 PRECEDING ) ;; }
      # derived_column: avg_volume_53_weeks_ago  { sql: AVG(volume) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC ROWS BETWEEN 377 PRECEDING AND 371 PRECEDING ) ;; }
      # derived_column: avg_volume_104_weeks_ago { sql: AVG(volume) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC ROWS BETWEEN 734 PRECEDING AND 728 PRECEDING ) ;; }
      # derived_column: avg_volume_105_weeks_ago { sql: AVG(volume) OVER (PARTITION BY coid_department, shift ORDER BY census_date ASC ROWS BETWEEN 741 PRECEDING AND 735 PRECEDING ) ;; }
    }
  }

######################
### Original Dimensions
######################

  dimension: pk {
    primary_key: yes
    sql: ${coid_department} || ' | ' || ${census_date} || ' | ' || ${shift} ;;
  }

  dimension: coid {}

  dimension: coid_department {}

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
    datatype: date
    sql: cast(${TABLE}.census_date as date) ;;
  }

  dimension: prediction_group {}

  dimension: shift {}

  dimension: volume {
    type: number
  }

  dimension: volume_6_week_ago_same_day_of_week { group_label: "Z - Input Parameters" type: number }
  dimension: volume_7_week_ago_same_day_of_week { group_label: "Z - Input Parameters" type: number }
  dimension: volume_8_week_ago_same_day_of_week { group_label: "Z - Input Parameters" type: number }
  dimension: volume_9_week_ago_same_day_of_week { group_label: "Z - Input Parameters" type: number }
  # dimension: volume_52_week_ago_same_day_of_week { group_label: "Z - Input Parameters" type: number }
  # dimension: volume_53_week_ago_same_day_of_week { group_label: "Z - Input Parameters" type: number }
  # dimension: volume_104_week_ago_same_day_of_week { group_label: "Z - Input Parameters" type: number }
  # dimension: volume_105_week_ago_same_day_of_week { group_label: "Z - Input Parameters" type: number }
  dimension: avg_volume_6_weeks_ago { group_label: "Z - Input Parameters" type: number }
  dimension: avg_volume_7_weeks_ago { group_label: "Z - Input Parameters" type: number }
  dimension: avg_volume_8_weeks_ago { group_label: "Z - Input Parameters" type: number }
  dimension: avg_volume_9_weeks_ago { group_label: "Z - Input Parameters" type: number }
  # dimension: avg_volume_52_weeks_ago { group_label: "Z - Input Parameters" type: number }
  # dimension: avg_volume_53_weeks_ago { group_label: "Z - Input Parameters" type: number }
  # dimension: avg_volume_104_weeks_ago { group_label: "Z - Input Parameters" type: number }
  # dimension: avg_volume_105_weeks_ago { group_label: "Z - Input Parameters" type: number }

######################
### Derived Dimensions
######################

  dimension: percent_change_volume_6_9_weeks {
    group_label: "Z - Input Parameters"
    type: number
    sql: (${volume_6_week_ago_same_day_of_week} - ${volume_9_week_ago_same_day_of_week}) / nullif(${volume_9_week_ago_same_day_of_week},0) ;;
    value_format_name: percent_1
  }

  dimension: percent_change_volume_8_9_weeks {
    group_label: "Z - Input Parameters"
    type: number
    sql: (${volume_8_week_ago_same_day_of_week} - ${volume_9_week_ago_same_day_of_week}) / nullif(${volume_9_week_ago_same_day_of_week},0) ;;
    value_format_name: percent_1
  }

  # dimension: percent_change_volume_52_9_weeks {
  #   group_label: "Z - Input Parameters"
  #   type: number
  #   sql: (${volume_9_week_ago_same_day_of_week} - ${volume_52_week_ago_same_day_of_week}) / nullif(${volume_52_week_ago_same_day_of_week},0) ;;
  #   value_format_name: percent_1
  # }

  # dimension: percent_change_volume_104_52_weeks {
  #   group_label: "Z - Input Parameters"
  #   type: number
  #   sql: (${volume_52_week_ago_same_day_of_week} - ${volume_104_week_ago_same_day_of_week}) / nullif(${volume_104_week_ago_same_day_of_week},0) ;;
  #   value_format_name: percent_1
  # }

  # dimension: percent_change_volume_53_52_weeks {
  #   group_label: "Z - Input Parameters"
  #   type: number
  #   sql: (${volume_52_week_ago_same_day_of_week} - ${volume_53_week_ago_same_day_of_week}) / nullif(${volume_53_week_ago_same_day_of_week},0) ;;
  #   value_format_name: percent_1
  # }

  # dimension: percent_change_volume_105_104_weeks {
  #   group_label: "Z - Input Parameters"
  #   type: number
  #   sql: (${volume_104_week_ago_same_day_of_week} - ${volume_105_week_ago_same_day_of_week}) / nullif(${volume_105_week_ago_same_day_of_week},0) ;;
  #   value_format_name: percent_1
  # }

######################
### Measures
######################

  measure: total_volume {
    type: sum
    sql: ${volume} ;;
  }
}

view: median_calc_pre {
  derived_table: {
    datagroup_trigger: new_data
    explore_source: volume_by_facility_by_shift_by_day {
      column: pk {}
      column: volume_6_week_ago_same_day_of_week {}
      column: volume_7_week_ago_same_day_of_week {}
      column: volume_8_week_ago_same_day_of_week {}
      column: volume_9_week_ago_same_day_of_week {}
    }
  }
  dimension: pk {}
  dimension: volume_6_week_ago_same_day_of_week { type: number }
  dimension: volume_7_week_ago_same_day_of_week { type: number }
  dimension: volume_8_week_ago_same_day_of_week { type: number }
  dimension: volume_9_week_ago_same_day_of_week { type: number }


}

view: median_calc {
  derived_table: {
    datagroup_trigger: new_data
    sql:
    SELECT distinct pk, PERCENTILE_CONT(value, 0.5) OVER (PARTITION BY pk) as median
    FROM
    (
                SELECT pk, volume_6_week_ago_same_day_of_week as value FROM ${median_calc_pre.SQL_TABLE_NAME}
      UNION ALL SELECT pk, volume_7_week_ago_same_day_of_week as value FROM ${median_calc_pre.SQL_TABLE_NAME}
      UNION ALL SELECT pk, volume_8_week_ago_same_day_of_week as value FROM ${median_calc_pre.SQL_TABLE_NAME}
      UNION ALL SELECT pk, volume_9_week_ago_same_day_of_week as value FROM ${median_calc_pre.SQL_TABLE_NAME}
    ) a
    ;;
  }

  dimension: pk {
    primary_key: yes
  }
  dimension: median {
    type: number
  }
  measure: average_median {
    type: average
    sql: ${median} ;;
  }
}

view: summary_predictions {
  derived_table: {
    datagroup_trigger: new_data
    explore_source: volume_by_facility_by_shift_by_day {
      column: pk { field: volume_by_facility_by_shift_by_day.pk }
      column: actual_value { field: volume_by_facility_by_shift_by_day.total_volume }
      column: prediction_median { field: median_calc.average_median }
      column: prediction_bqml { field: volume_prediction.average_predicted_volume }
      filters: {
        field: volume_prediction.pk
        value: "-EMPTY"
      }
    }
  }
  dimension: pk {
    primary_key: yes
  }
  dimension: actual_value {
    type: number
  }
  dimension: prediction_median {
    type: number
  }
  dimension: prediction_bqml {
    value_format: "#,##0.0"
    type: number
  }
  measure: average_actual_value {
    type: average
    sql: ${actual_value} ;;
    value_format_name: decimal_1
  }
  measure: average_prediction_median {
    type: average
    sql: ${prediction_median} ;;
    value_format_name: decimal_1
  }
  measure: average_prediction_bqml {
    type: average
    sql: ${prediction_bqml} ;;
    value_format_name: decimal_1
  }

  measure: median_percent_accuracy {
    type: number
    sql: 1 - (abs(${average_prediction_median} - ${average_actual_value}) / nullif(${average_actual_value},0)) ;;
    value_format_name: percent_1
  }
  measure: bqml_percent_accuracy {
    type: number
    sql: 1 - (abs(${average_prediction_bqml} - ${average_actual_value}) / nullif(${average_actual_value},0)) ;;
    value_format_name: percent_1
  }
  measure: bqml_vs_median_accuracy {
    type: number
    sql: ${bqml_percent_accuracy} - ${median_percent_accuracy} ;;
    value_format_name: percent_1
  }
}

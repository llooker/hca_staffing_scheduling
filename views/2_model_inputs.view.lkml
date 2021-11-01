view: volume_by_facility_by_shift_by_day {
  derived_table: {
    datagroup_trigger: new_data
    explore_source: staffing_volume_predictions_1_load_raw_data {
      column: facility_id {}
      column: operation_date {}
      column: shift {}
      column: volume {}
      derived_column: volume_6_week_ago_same_day_of_week   { sql: LAG(volume, 42) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC) ;; }
      derived_column: volume_7_week_ago_same_day_of_week   { sql: LAG(volume, 49) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC) ;; }
      derived_column: volume_8_week_ago_same_day_of_week   { sql: LAG(volume, 56) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC) ;; }
      derived_column: volume_9_week_ago_same_day_of_week   { sql: LAG(volume, 63) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC) ;; }
      derived_column: volume_52_week_ago_same_day_of_week  { sql: LAG(volume, 364) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC) ;; }
      derived_column: volume_53_week_ago_same_day_of_week  { sql: LAG(volume, 371) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC) ;; }
      derived_column: volume_104_week_ago_same_day_of_week { sql: LAG(volume, 728) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC) ;; }
      derived_column: volume_105_week_ago_same_day_of_week { sql: LAG(volume, 735) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC) ;; }
      derived_column: avg_volume_6_weeks_ago   { sql: AVG(volume) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC ROWS BETWEEN 48 PRECEDING AND 42 PRECEDING ) ;; }
      derived_column: avg_volume_7_weeks_ago   { sql: AVG(volume) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC ROWS BETWEEN 55 PRECEDING AND 49 PRECEDING ) ;; }
      derived_column: avg_volume_8_weeks_ago   { sql: AVG(volume) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC ROWS BETWEEN 62 PRECEDING AND 56 PRECEDING ) ;; }
      derived_column: avg_volume_9_weeks_ago   { sql: AVG(volume) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC ROWS BETWEEN 69 PRECEDING AND 63 PRECEDING ) ;; }
      derived_column: avg_volume_52_weeks_ago  { sql: AVG(volume) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC ROWS BETWEEN 370 PRECEDING AND 364 PRECEDING ) ;; }
      derived_column: avg_volume_53_weeks_ago  { sql: AVG(volume) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC ROWS BETWEEN 377 PRECEDING AND 371 PRECEDING ) ;; }
      derived_column: avg_volume_104_weeks_ago { sql: AVG(volume) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC ROWS BETWEEN 734 PRECEDING AND 728 PRECEDING ) ;; }
      derived_column: avg_volume_105_weeks_ago { sql: AVG(volume) OVER (PARTITION BY facility_id, shift ORDER BY operation_date ASC ROWS BETWEEN 741 PRECEDING AND 735 PRECEDING ) ;; }
    }
  }

######################
### Original Dimensions
######################

  dimension: pk {
    primary_key: yes
    sql: ${facility_id} || ' | ' || ${operation_date} || ' | ' || ${shift} ;;
  }

  dimension: facility_id {}

  dimension: operation_date {
    type: date
  }

  dimension: shift {}

  dimension: volume {
    type: number
  }

  dimension: volume_6_week_ago_same_day_of_week { type: number }
  dimension: volume_7_week_ago_same_day_of_week { type: number }
  dimension: volume_8_week_ago_same_day_of_week { type: number }
  dimension: volume_9_week_ago_same_day_of_week { type: number }
  dimension: volume_52_week_ago_same_day_of_week { type: number }
  dimension: volume_53_week_ago_same_day_of_week { type: number }
  dimension: volume_104_week_ago_same_day_of_week { type: number }
  dimension: volume_105_week_ago_same_day_of_week { type: number }
  dimension: avg_volume_6_weeks_ago { type: number }
  dimension: avg_volume_7_weeks_ago { type: number }
  dimension: avg_volume_8_weeks_ago { type: number }
  dimension: avg_volume_9_weeks_ago { type: number }
  dimension: avg_volume_52_weeks_ago { type: number }
  dimension: avg_volume_53_weeks_ago { type: number }
  dimension: avg_volume_104_weeks_ago { type: number }
  dimension: avg_volume_105_weeks_ago { type: number }

######################
### Derived Dimensions
######################

  dimension: percent_change_volume_6_9_weeks {
    type: number
    sql: (${volume_6_week_ago_same_day_of_week} - ${volume_9_week_ago_same_day_of_week}) / nullif(${volume_9_week_ago_same_day_of_week},0) ;;
    value_format_name: percent_1
  }

  dimension: percent_change_volume_8_9_weeks {
    type: number
    sql: (${volume_8_week_ago_same_day_of_week} - ${volume_9_week_ago_same_day_of_week}) / nullif(${volume_9_week_ago_same_day_of_week},0) ;;
    value_format_name: percent_1
  }

  dimension: percent_change_volume_52_9_weeks {
    type: number
    sql: (${volume_9_week_ago_same_day_of_week} - ${volume_52_week_ago_same_day_of_week}) / nullif(${volume_52_week_ago_same_day_of_week},0) ;;
    value_format_name: percent_1
  }

  dimension: percent_change_volume_104_52_weeks {
    type: number
    sql: (${volume_52_week_ago_same_day_of_week} - ${volume_104_week_ago_same_day_of_week}) / nullif(${volume_104_week_ago_same_day_of_week},0) ;;
    value_format_name: percent_1
  }

  dimension: percent_change_volume_53_52_weeks {
    type: number
    sql: (${volume_52_week_ago_same_day_of_week} - ${volume_53_week_ago_same_day_of_week}) / nullif(${volume_53_week_ago_same_day_of_week},0) ;;
    value_format_name: percent_1
  }

  dimension: percent_change_volume_105_104_weeks {
    type: number
    sql: (${volume_104_week_ago_same_day_of_week} - ${volume_105_week_ago_same_day_of_week}) / nullif(${volume_105_week_ago_same_day_of_week},0) ;;
    value_format_name: percent_1
  }

######################
### Measures
######################

  measure: total_volume {
    type: sum
    sql: ${volume} ;;
  }
}

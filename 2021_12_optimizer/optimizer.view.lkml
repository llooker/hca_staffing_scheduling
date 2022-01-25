view: optimizer {
  sql_table_name: `hca-data-sandbox.staffing_scheduling.optimizer_105_output_of_optimizer`
    ;;

#######################
### Original Dimensions
#######################

  dimension: counter_id {
    type: number
    sql: ${TABLE}.counter_id ;;
  }

  dimension: day_of_week {
    type: number
    sql: ${TABLE}.day_of_week ;;
  }

  dimension: dow_tod_preference {
    type: number
    sql: ${TABLE}.dow_tod_preference ;;
  }

  dimension: grand_total {
    type: number
    sql: ${TABLE}.grand_total ;;
  }

  dimension: is_preferred_slot {
    type: number
    sql: ${TABLE}.is_preferred_slot ;;
  }

  dimension: is_staffed {
    type: number
    sql: ${TABLE}.is_staffed ;;
  }

  dimension: is_unavailable {
    type: number
    sql: ${TABLE}.is_unavailable ;;
  }

  dimension: is_weekend {
    type: number
    sql: ${TABLE}.is_weekend ;;
  }

  dimension: max_shifts {
    type: number
    sql: ${TABLE}.max_shifts ;;
  }

  dimension: min_shifts {
    type: number
    sql: ${TABLE}.min_shifts ;;
  }

  dimension: score_dow_tod {
    type: number
    sql: ${TABLE}.score_dow_tod ;;
  }

  dimension: score_five_day_shift {
    type: number
    sql: ${TABLE}.score_five_day_shift ;;
  }

  dimension: score_nine_day_shift {
    type: number
    sql: ${TABLE}.score_nine_day_shift ;;
  }

  dimension: score_preferred {
    type: number
    sql: ${TABLE}.score_preferred ;;
  }

  dimension: score_rank {
    type: number
    sql: ${TABLE}.score_rank ;;
  }

  dimension: score_shifts_outstanding {
    type: number
    sql: ${TABLE}.score_shifts_outstanding ;;
  }

  dimension: score_three_consecutive {
    type: number
    sql: ${TABLE}.score_three_consecutive ;;
  }

  dimension: score_two_consecutive {
    type: number
    sql: ${TABLE}.score_two_consecutive ;;
  }

  dimension: score_unavailable {
    type: number
    sql: ${TABLE}.score_unavailable ;;
  }

  dimension: shift_applied {
    type: number
    sql: ${TABLE}.shift_applied ;;
  }

  dimension: shift_id {
    type: number
    sql: ${TABLE}.shift_id ;;
  }

  dimension: shift_outstanding {
    type: number
    sql: ${TABLE}.shift_outstanding ;;
  }

  dimension: shift_required {
    type: number
    sql: ${TABLE}.shift_required ;;
  }

  dimension_group: shift_timestamp {
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
    sql: ${TABLE}.shift_timestamp ;;
  }

  dimension: staff_applied {
    type: number
    sql: ${TABLE}.staff_applied ;;
  }

  dimension: staff_id {
    type: number
    sql: ${TABLE}.staff_id ;;
  }

  dimension: staff_outstanding {
    type: number
    sql: ${TABLE}.staff_outstanding ;;
  }

  dimension: staff_required {
    type: number
    sql: ${TABLE}.staff_required ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: tenure {
    type: number
    sql: ${TABLE}.tenure ;;
  }

  dimension: time_of_day {
    type: string
    sql: ${TABLE}.time_of_day ;;
  }

#######################
### Derived Dimensions
#######################

  dimension: tenure_tier {
    type: tier
    sql: ${tenure} ;;
    tiers: [5,10]
    style: integer
  }

#######################
### Measures
#######################


  measure: count {
    type: count
    drill_fields: []
  }

  measure: average_shift_outstanding {
    type: average
    sql: ${shift_outstanding} ;;
    value_format_name: decimal_1
  }

  measure: average_staff_outstanding {
    type: average
    sql: ${staff_outstanding} ;;
    value_format_name: decimal_1
  }

  measure: average_score {
    type: average
    sql: ${grand_total} ;;
    value_format_name: decimal_1
  }

  measure: average_counter_id {
    type: average
    sql: ${counter_id} ;;
    value_format_name: decimal_1
  }

  measure: count_unavailable_shifts {
    type: count
    filters: [is_unavailable: "1"]
  }

  measure: count_unavailable_shifts_staffed {
    type: count
    filters: [is_unavailable: "1", is_staffed: "1"]
  }

  measure: percent_unavailable_shifts_staffed {
    type: number
    sql: ${count_unavailable_shifts_staffed} / nullif(${count_unavailable_shifts},0) ;;
    value_format_name: percent_1
  }

  measure: count_prefered_shifts {
    type: count
    filters: [is_preferred_slot: "1"]
  }

  measure: count_prefered_shifts_staffed {
    type: count
    filters: [is_preferred_slot: "1", is_staffed: "1"]
  }

  measure: percent_preferred_shifts_staffed {
    type: number
    sql: ${count_prefered_shifts_staffed} / nullif(${count_prefered_shifts},0) ;;
    value_format_name: percent_1
  }

  measure: count_staffed_shifts {
    type: count
    filters: [is_staffed: "1"]
  }

  measure: count_two_consecutive_shifts {
    type: count
    filters: [score_two_consecutive: "-100"]
  }

  measure: count_three_consecutive_shifts {
    type: count
    filters: [score_three_consecutive: "-100"]
  }

  measure: percent_two_consecutive_shifts {
    type: number
    sql: ${count_two_consecutive_shifts} / nullif(${count_staffed_shifts},0) ;;
    value_format_name: percent_1
  }

  measure: percent_three_consecutive_shifts {
    type: number
    sql: ${count_three_consecutive_shifts} / nullif(${count_staffed_shifts},0) ;;
    value_format_name: percent_1
  }

  measure: max_staff_applied {
    type: sum
    sql: ${is_staffed} ;;
    # filters: [s: ">=0"]
  }

  measure: max_staff_required {
    type: max
    sql: ${staff_required} ;;
  }

  measure: percent_staffed {
    type: number
    sql: ${max_staff_applied} / nullif((${max_staff_required}),0) ;;
    value_format_name: percent_1
  }

  measure: max_shift_applied {
    type: sum
    sql: ${is_staffed} ;;
    # filters: [shift_outstanding: ">=0"]
  }

  measure: max_shift_required {
    type: max
    sql: ${max_shifts} ;;
    # filters: [shift_outstanding: ">=0"]
  }

  measure: percent_shifts {
    type: number
    sql: ${max_shift_applied} / nullif(${max_shift_required},0) ;;
    value_format_name: percent_1
  }


}

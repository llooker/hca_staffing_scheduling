view: results {
  sql_table_name:
  (
                SELECT * FROM `hca-data-sandbox.staffing_scheduling.demand_forecasting_5_summary_results`
      UNION ALL SELECT * FROM `hca-data-sandbox.staffing_scheduling.demand_forecasting_baseline_5_summary_results`
      UNION ALL SELECT * FROM  `hca-data-sandbox.staffing_scheduling.demand_forecasting_markov_3_summary_results`
  )
  ;;

#######################
### Original Dimensions
#######################

  dimension: pk {
    primary_key: yes
    type: string
    sql: ${model_type} || ' | ' || ${counter_id} ;;
  }

  dimension: model_description {
    type: string
    sql: ${model_type} || ' | ' || ${days_prior_to_forecast} || ' Days Out | ' || ${start_date} || ' Start | ' || coalesce(${hour_band},24) || ' Hour Band';;
  }

  dimension: counter_id {
    type: number
    sql: ${TABLE}.counter_id ;;
  }

  dimension: days_prior_to_forecast {
    type: number
    sql: ${TABLE}.days_prior_to_forecast ;;
  }

  dimension: hour_band {
    type: number
    sql: ${TABLE}.hour_band ;;
  }

  dimension: model_outputs {
    hidden: yes
    sql: ${TABLE}.model_outputs ;;
  }

  dimension: model_type {
    type: string
    sql: ${TABLE}.model_type ;;
  }

  dimension: model_type_2 {
    type: string
    sql:
      case
        when lower(${model_type}) like '%arima%' then 'ARIMA'
        when lower(${model_type}) like '%mark%' then 'Markov'
        else 'Baseline'
      end ;;
  }

  dimension_group: start {
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
    sql: ${TABLE}.start_date ;;
  }

#######################
### Derived Dimensions
#######################

#######################
### Measures
#######################

  measure: count {
    type: count
    drill_fields: []
  }
}

view: model_outputs {

#######################
### Original Dimensions
#######################

  dimension: pk {
    primary_key: yes
    type: string
    sql: ${key} || ' | ' || ${census_time_raw} ;;
  }

  dimension: actual {
    group_label: "Quant"
    type: number
    sql: ${TABLE}.actual ;;
    value_format_name: decimal_1
  }

  dimension_group: census {
    type: time
    hidden: yes
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
    sql: ${TABLE}.census_date ;;
  }

  dimension_group: census_time {
    type: time
    timeframes: [
      raw,
      hour,
      hour_of_day,
      day_of_week,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    sql: ${TABLE}.census_time ;;
  }

  dimension: days_since_prediction {
    type: number
    sql: ${TABLE}.days_since_prediction ;;
  }

  dimension: expected {
    group_label: "Quant"
    type: number
    sql: ceil(${TABLE}.expected,0) ;;
    value_format_name: decimal_1
  }

  dimension: expected_upper_bound_ci_10 {
    group_label: "Quant"
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_10 ;;
    value_format_name: decimal_1
  }

  dimension: expected_upper_bound_ci_20 {
    group_label: "Quant"
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_20 ;;
    value_format_name: decimal_1
  }

  dimension: expected_upper_bound_ci_30 {
    group_label: "Quant"
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_30 ;;
    value_format_name: decimal_1
  }

  dimension: expected_upper_bound_ci_40 {
    group_label: "Quant"
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_40 ;;
    value_format_name: decimal_1
  }

  dimension: expected_upper_bound_ci_50 {
    group_label: "Quant"
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_50 ;;
    value_format_name: decimal_1
  }

  dimension: expected_upper_bound_ci_60 {
    group_label: "Quant"
    type: number
    sql: ${TABLE}.expected_upper_bound_ci_60 ;;
    value_format_name: decimal_1
  }

  dimension: hospital {
    type: string
    sql: ${TABLE}.hospital ;;
  }

  dimension: hour_of_day {
    type: string
    sql: ${TABLE}.hour_of_day ;;
  }

  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
  }

#######################
### Derived Dimensions
#######################

  parameter: expected_kpi {
    type: unquoted
    default_value: "expected"
    allowed_value: { label: "Expected Value" value: "expected" }
    allowed_value: { label: "Upper Bound, 10% CI" value: "ci10" }
    allowed_value: { label: "Upper Bound, 20% CI" value: "ci20" }
    allowed_value: { label: "Upper Bound, 30% CI" value: "ci30" }
    allowed_value: { label: "Upper Bound, 40% CI" value: "ci40" }
    allowed_value: { label: "Upper Bound, 50% CI" value: "ci50" }
    allowed_value: { label: "Upper Bound, 60% CI" value: "ci60" }
  }

  dimension: expected_dynamic {
    group_label: "Quant"
    type: number
    sql:
      {% if    expected_kpi._parameter_value == 'ci10' %} ${expected_upper_bound_ci_10}
      {% elsif expected_kpi._parameter_value == 'ci20' %} ${expected_upper_bound_ci_20}
      {% elsif expected_kpi._parameter_value == 'ci30' %} ${expected_upper_bound_ci_30}
      {% elsif expected_kpi._parameter_value == 'ci40' %} ${expected_upper_bound_ci_40}
      {% elsif expected_kpi._parameter_value == 'ci50' %} ${expected_upper_bound_ci_50}
      {% elsif expected_kpi._parameter_value == 'ci60' %} ${expected_upper_bound_ci_60}
      {% else %} ${expected}
      {% endif %}
    ;;
    value_format_name: decimal_1
  }

  parameter: percent_increase {
    type: number
    default_value: "0"
  }

  # dimension: actual_updated {
  #   group_label: "Quant"
  #   sql:
  #     case
  #       when ${results.model_type} = 'Baseline' then ${actual}
  #       else ${actual} * (1 + {% parameter percent_increase %})
  #     end
  #   ;;
  # }

  dimension: difference_abs {
    group_label: "Quant"
    type: number
    sql: ${actual} - ${expected_dynamic} ;;
    value_format_name: decimal_1
  }

  dimension: difference_abs_squared {
    group_label: "Quant"
    type: number
    sql: pow(${difference_abs},2) ;;
    value_format_name: decimal_1
  }

  dimension: difference_perc {
    group_label: "Quant"
    type: number
    sql: ${difference_abs} / nullif(${actual},0) ;;
    value_format_name: percent_1
  }

  dimension: score_buckets {
    type: string
    sql:
      case
        when ${difference_perc} > 0.9 or ${difference_perc} < -0.5 then '5 - Black'
        when ${difference_perc} > 0.7 or ${difference_perc} < -0.4 then '4 - Red'
        when ${difference_perc} > 0.5 or ${difference_perc} < -0.3 then '3 - Orange'
        when ${difference_perc} > 0.3 or ${difference_perc} < -0.2 then '2 - Yellow'
        else '1 - Green'
      end
    ;;
  }
  dimension: score_number {
    type: number
    sql:
      case
        when ${score_buckets} like '%5%' then -1000
        when ${score_buckets} like '%4%' then -500
        when ${score_buckets} like '%3%' then -100
        when ${score_buckets} like '%2%' then -10
        else 0
      end
    ;;
  }
  dimension: days_since_prediction_buckets {
    type: tier
    sql: ${days_since_prediction} ;;
    tiers: [7,14,30,60,90,180]
    style: integer
  }
  dimension: score_buckets_3 {
    type: string
    sql:
      case
        when ${difference_perc} > 0.5 or ${difference_perc} < -0.5 then 'C - Very Wrong'
        when ${difference_perc} > 0.2 or ${difference_perc} < -0.2 then 'B - Wrong'
        else 'A - Correct'
      end
    ;;
  }

#######################
### Measures
#######################

## RMSE
  measure: average_squared {
    group_label: "Quant"
    type: average
    sql: ${difference_abs_squared} ;;
  }

  measure: rmse {
    label: "RMSE"
    type: number
    sql: pow(${average_squared},0.5) ;;
    value_format_name: decimal_1
  }

  measure: average_actual {
    group_label: "Quant"
    type: average
    sql: ${actual} ;;
    value_format_name: decimal_1
  }

  measure: average_expected {
    group_label: "Quant"
    type: average
    sql: ${expected} ;;
    value_format_name: decimal_1
  }

  measure: average_diff_abs {
    group_label: "Quant"
    type: average
    sql: ${difference_abs} ;;
    value_format_name: decimal_1
  }

  measure: average_diff_perc {
    group_label: "Quant"
    type: average
    sql: ${difference_perc} ;;
    value_format_name: percent_1
  }

  measure: average_diff_abs_squared {
    group_label: "Quant"
    type: average
    sql: ${difference_abs_squared} ;;
    value_format_name: decimal_1
  }

  measure: total_score {
    hidden: yes
    type: sum
    sql: ${score_number} ;;
    value_format_name: decimal_1
  }
  measure: average_score {
    type: average
    sql: ${score_number} ;;
    value_format_name: decimal_1
  }
  measure: number_cat_5 {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets: "5%"]
  }
  measure: number_cat_4 {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets: "4%"]
  }
  measure: number_cat_3 {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets: "3%"]
  }
  measure: number_cat_2 {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets: "2%"]
  }
  measure: number_cat_1 {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets: "1%"]
  }
  measure: number_cat_5_or_4 {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets: "5%, 4%"]
  }
  measure: number_total {
    group_label: "# - Each Bucket"
    type: count
  }
  measure: count {
    type: count
  }
  measure: percent_cat_5 {
    group_label: "% - Each Bucket"
    type: number
    sql: ${number_cat_5} / nullif(${number_total},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_4 {
    group_label: "% - Each Bucket"
    type: number
    sql: ${number_cat_4} / nullif(${number_total},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_3 {
    group_label: "% - Each Bucket"
    type: number
    sql: ${number_cat_3} / nullif(${number_total},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_2 {
    group_label: "% - Each Bucket"
    type: number
    sql: ${number_cat_2} / nullif(${number_total},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_1 {
    group_label: "% - Each Bucket"
    type: number
    sql: ${number_cat_1} / nullif(${number_total},0) ;;
    value_format_name: percent_1
  }
  measure: number_cat_a {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets_3: "A%"]
  }
  measure: number_cat_b {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets_3: "B%"]
  }
  measure: number_cat_c {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets_3: "C%"]
  }
  measure: number_cat_b_c {
    group_label: "# - Each Bucket"
    type: count
    filters: [score_buckets_3: "B%, C%"]
  }
  measure: percent_cat_a {
    group_label: "% - Each Bucket"
    type: number
    sql: ${number_cat_a} / nullif(${number_total},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_b {
    group_label: "% - Each Bucket"
    type: number
    sql: ${number_cat_b} / nullif(${number_total},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_c {
    group_label: "% - Each Bucket"
    type: number
    sql: ${number_cat_c} / nullif(${number_total},0) ;;
    value_format_name: percent_1
  }
  measure: percent_cat_b_c {
    group_label: "% - Each Bucket"
    type: number
    sql: ${number_cat_b_c} / nullif(${number_total},0) ;;
    value_format_name: percent_1
  }
}

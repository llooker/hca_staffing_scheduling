
######################## TRAINING/TESTING INPUTS #############################
view: training_input {
  derived_table: {
    datagroup_trigger: new_data
    explore_source: volume_by_facility_by_shift_by_day {
      column: coid_department {}
      column: shift {}
      column: census_date {}
      column: volume {}
      column: volume_6_week_ago_same_day_of_week {}
      column: volume_7_week_ago_same_day_of_week {}
      column: volume_8_week_ago_same_day_of_week {}
      column: volume_9_week_ago_same_day_of_week {}
      # column: volume_52_week_ago_same_day_of_week {}
      # column: volume_53_week_ago_same_day_of_week {}
      # column: volume_104_week_ago_same_day_of_week {}
      # column: volume_105_week_ago_same_day_of_week {}
      column: avg_volume_6_weeks_ago {}
      column: avg_volume_7_weeks_ago {}
      column: avg_volume_8_weeks_ago {}
      column: avg_volume_9_weeks_ago {}
      # column: avg_volume_52_weeks_ago {}
      # column: avg_volume_53_weeks_ago {}
      # column: avg_volume_104_weeks_ago {}
      # column: avg_volume_105_weeks_ago {}
      column: percent_change_volume_6_9_weeks {}
      column: percent_change_volume_8_9_weeks {}
      # column: percent_change_volume_52_9_weeks {}
      # column: percent_change_volume_104_52_weeks {}
      # column: percent_change_volume_53_52_weeks {}
      # column: percent_change_volume_105_104_weeks {}
      filters: {
        field: volume_by_facility_by_shift_by_day.prediction_group
        value: "Train"
      }
    }
  }
}

view: testing_input {
  derived_table: {
    datagroup_trigger: new_data
    explore_source: volume_by_facility_by_shift_by_day {
      column: coid_department {}
      column: shift {}
      column: census_date {}
      column: volume {}
      column: volume_6_week_ago_same_day_of_week {}
      column: volume_7_week_ago_same_day_of_week {}
      column: volume_8_week_ago_same_day_of_week {}
      column: volume_9_week_ago_same_day_of_week {}
      # column: volume_52_week_ago_same_day_of_week {}
      # column: volume_53_week_ago_same_day_of_week {}
      # column: volume_104_week_ago_same_day_of_week {}
      # column: volume_105_week_ago_same_day_of_week {}
      column: avg_volume_6_weeks_ago {}
      column: avg_volume_7_weeks_ago {}
      column: avg_volume_8_weeks_ago {}
      column: avg_volume_9_weeks_ago {}
      # column: avg_volume_52_weeks_ago {}
      # column: avg_volume_53_weeks_ago {}
      # column: avg_volume_104_weeks_ago {}
      # column: avg_volume_105_weeks_ago {}
      column: percent_change_volume_6_9_weeks {}
      column: percent_change_volume_8_9_weeks {}
      # column: percent_change_volume_52_9_weeks {}
      # column: percent_change_volume_104_52_weeks {}
      # column: percent_change_volume_53_52_weeks {}
      # column: percent_change_volume_105_104_weeks {}
      filters: {
        field: volume_by_facility_by_shift_by_day.prediction_group
        value: "Test"
      }
    }
  }
}

view: future_input {
  derived_table: {
    datagroup_trigger: new_data
    explore_source: volume_by_facility_by_shift_by_day {
      column: coid_department {}
      column: shift {}
      column: census_date {}
      column: volume {}
      column: volume_6_week_ago_same_day_of_week {}
      column: volume_7_week_ago_same_day_of_week {}
      column: volume_8_week_ago_same_day_of_week {}
      column: volume_9_week_ago_same_day_of_week {}
      # column: volume_52_week_ago_same_day_of_week {}
      # column: volume_53_week_ago_same_day_of_week {}
      # column: volume_104_week_ago_same_day_of_week {}
      # column: volume_105_week_ago_same_day_of_week {}
      column: avg_volume_6_weeks_ago {}
      column: avg_volume_7_weeks_ago {}
      column: avg_volume_8_weeks_ago {}
      column: avg_volume_9_weeks_ago {}
      # column: avg_volume_52_weeks_ago {}
      # column: avg_volume_53_weeks_ago {}
      # column: avg_volume_104_weeks_ago {}
      # column: avg_volume_105_weeks_ago {}
      column: percent_change_volume_6_9_weeks {}
      column: percent_change_volume_8_9_weeks {}
      # column: percent_change_volume_52_9_weeks {}
      # column: percent_change_volume_104_52_weeks {}
      # column: percent_change_volume_53_52_weeks {}
      # column: percent_change_volume_105_104_weeks {}
      filters: {
        field: volume_by_facility_by_shift_by_day.prediction_group
        value: "Predict"
      }
    }
  }
}

######################## MODEL #############################

view: volume_model {
  derived_table: {
    datagroup_trigger: new_data
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(model_type='LINEAR_REG'
        , labels=['volume']
        , min_rel_progress = 0.005
        , max_iterations = 40
        -- , auto_class_weights=true
        ) AS
      SELECT
        * EXCEPT(coid_department, census_date)
      FROM ${training_input.SQL_TABLE_NAME};;
  }
}

######################## TRAINING INFORMATION #############################

view: volume_model_training_info {
  derived_table: {
    datagroup_trigger: new_data
    sql: SELECT  * FROM ml.TRAINING_INFO(MODEL ${volume_model.SQL_TABLE_NAME});;
  }
  dimension: training_run {type: number}
  dimension: iteration {type: number}
  dimension: loss_raw {sql: ${TABLE}.loss;; type: number hidden:yes}
  dimension: eval_loss {type: number}
  dimension: duration_ms {label:"Duration (ms)" type: number}
  dimension: learning_rate {type: number}
  measure: total_iterations {
    type: count
  }
  measure: loss {
    value_format_name: decimal_2
    type: sum
    sql:  ${loss_raw} ;;
  }
  measure: total_training_time {
    type: sum
    label:"Total Training Time (sec)"
    sql: ${duration_ms}/1000 ;;
    value_format_name: decimal_1
  }
  measure: average_iteration_time {
    type: average
    label:"Average Iteration Time (sec)"
    sql: ${duration_ms}/1000 ;;
    value_format_name: decimal_1
  }
}

view: volume_model_evaluation {
  derived_table: {
    datagroup_trigger: new_data
    sql: SELECT * FROM ml.EVALUATE(
          MODEL ${volume_model.SQL_TABLE_NAME},
          (SELECT * FROM ${testing_input.SQL_TABLE_NAME}));;
  }

  dimension: mean_absolute_error { type: number value_format_name: decimal_2 }
  dimension: mean_squared_error { type: number value_format_name: decimal_2 }
  dimension: mean_squared_log_error { type: number value_format_name: decimal_2 }
  dimension: median_absolute_error { type: number value_format_name: decimal_2 }
  dimension: r2_score { type: number value_format_name: decimal_2 }
  dimension: explained_variance { type: number value_format_name: decimal_2 }
}

view: volume_model_ml_weights {
  derived_table: {
    datagroup_trigger: new_data
    sql:
      SELECT a.processed_input, a.weight, b.weight as sub_weight, b.category
      FROM ML.WEIGHTS(MODEL ${volume_model.SQL_TABLE_NAME}) a
      LEFT JOIN UNNEST(a.category_weights) b
    ;;
    #
  }
  dimension: processed_input {}
  dimension: category {}
  dimension: weight {
    type: number
    value_format_name: decimal_2
  }
  dimension: sub_weight {
    type: number
    value_format_name: decimal_2
  }
}

# ########################################## PREDICT FUTURE ############################

view: volume_prediction {
  derived_table: {
    datagroup_trigger: new_data
    sql: SELECT * FROM ml.PREDICT(
          MODEL ${volume_model.SQL_TABLE_NAME},
          (SELECT * FROM ${future_input.SQL_TABLE_NAME}));;
  }

  dimension: pk {
    primary_key: yes
    sql: ${coid_department} || ' | ' || ${census_date} || ' | ' || ${shift} ;;
  }

  dimension: coid_department {}

  dimension: census_date {
    type: date
  }

  dimension: shift {}

  dimension: volume {
    type: number
  }

  dimension: predicted_volume {
    type: number
    value_format_name: decimal_1
    sql: case when ${TABLE}.predicted_volume < 0 then 0 else ${TABLE}.predicted_volume end ;;
  }

  dimension: residual_absolute {
    type: number
    sql: ${volume} - ${predicted_volume} ;;
    value_format_name: decimal_1
  }

  dimension: residual_percent {
    type: number
    sql: ${residual_absolute} / nullif(${predicted_volume},0) ;;
    value_format_name: percent_1
  }

  measure: average_volume {
    type: average
    sql: ${volume} ;;
    value_format_name: decimal_1
  }

  measure: average_predicted_volume {
    type: average
    sql: ${predicted_volume} ;;
    value_format_name: decimal_1
  }

  measure: average_residual_absolute {
    type: average
    sql: ${residual_absolute} ;;
    value_format_name: decimal_1
  }

  measure: average_residual_percent {
    type: number
    sql: ${average_residual_absolute} / nullif(${average_predicted_volume},0) ;;
    value_format_name: percent_1
  }
}

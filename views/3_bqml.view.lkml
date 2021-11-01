
######################## TRAINING/TESTING INPUTS #############################
view: training_input {
  derived_table: {
    datagroup_trigger: new_data
    explore_source: volume_by_facility_by_shift_by_day {
      column: facility_id {}
      column: shift {}
      column: volume {}
      column: volume_6_week_ago_same_day_of_week {}
      column: volume_7_week_ago_same_day_of_week {}
      column: volume_8_week_ago_same_day_of_week {}
      column: volume_9_week_ago_same_day_of_week {}
      column: volume_52_week_ago_same_day_of_week {}
      column: volume_53_week_ago_same_day_of_week {}
      column: volume_104_week_ago_same_day_of_week {}
      column: volume_105_week_ago_same_day_of_week {}
      column: avg_volume_6_weeks_ago {}
      column: avg_volume_7_weeks_ago {}
      column: avg_volume_8_weeks_ago {}
      column: avg_volume_9_weeks_ago {}
      column: avg_volume_52_weeks_ago {}
      column: avg_volume_53_weeks_ago {}
      column: avg_volume_104_weeks_ago {}
      column: avg_volume_105_weeks_ago {}
      column: percent_change_volume_6_9_weeks {}
      column: percent_change_volume_8_9_weeks {}
      column: percent_change_volume_52_9_weeks {}
      column: percent_change_volume_104_52_weeks {}
      column: percent_change_volume_53_52_weeks {}
      column: percent_change_volume_105_104_weeks {}
      filters: {
        field: volume_by_facility_by_shift_by_day.operation_date
        value: "2000/01/01 to 2003/01/01"
      }
    }
  }
}

view: testing_input {
  derived_table: {
    datagroup_trigger: new_data
    explore_source: volume_by_facility_by_shift_by_day {
      column: facility_id {}
      column: shift {}
      column: volume {}
      column: volume_6_week_ago_same_day_of_week {}
      column: volume_7_week_ago_same_day_of_week {}
      column: volume_8_week_ago_same_day_of_week {}
      column: volume_9_week_ago_same_day_of_week {}
      column: volume_52_week_ago_same_day_of_week {}
      column: volume_53_week_ago_same_day_of_week {}
      column: volume_104_week_ago_same_day_of_week {}
      column: volume_105_week_ago_same_day_of_week {}
      column: avg_volume_6_weeks_ago {}
      column: avg_volume_7_weeks_ago {}
      column: avg_volume_8_weeks_ago {}
      column: avg_volume_9_weeks_ago {}
      column: avg_volume_52_weeks_ago {}
      column: avg_volume_53_weeks_ago {}
      column: avg_volume_104_weeks_ago {}
      column: avg_volume_105_weeks_ago {}
      column: percent_change_volume_6_9_weeks {}
      column: percent_change_volume_8_9_weeks {}
      column: percent_change_volume_52_9_weeks {}
      column: percent_change_volume_104_52_weeks {}
      column: percent_change_volume_53_52_weeks {}
      column: percent_change_volume_105_104_weeks {}
      filters: {
        field: volume_by_facility_by_shift_by_day.operation_date
        value: "2003/01/01 to 2005/01/01"
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
        * EXCEPT(facility_id)
      FROM ${training_input.SQL_TABLE_NAME};;
  }
}

######################## TRAINING INFORMATION #############################

# VIEWS:
view: volume_model_evaluation {
  derived_table: {
    datagroup_trigger: new_data
    sql: SELECT * FROM ml.EVALUATE(
          MODEL ${volume_model.SQL_TABLE_NAME},
          (SELECT * FROM ${testing_input.SQL_TABLE_NAME}));;
  }

  dimension: mean_absolute_error { type: number }
  dimension: mean_squared_error { type: number }
  dimension: mean_squared_log_error { type: number }
  dimension: median_absolute_error { type: number }
  dimension: r2_score { type: number }
  dimension: explained_variance { type: number }
}

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


  # dimension: recall {
  #   type: number
  #   value_format_name:percent_2
  #   description: "True positives over all positives."
  # }
  # dimension: precision {
  #   type: number
  #   value_format_name:percent_2
  #   description: "True positives over true positives + false negatives."
  # }


#   dimension: accuracy {type: number value_format_name:percent_2}
#   ### Accuracy of the model evaluations ###


#   dimension: f1_score {type: number value_format_name:percent_3}
#   dimension: log_loss {type: number}
#   dimension: roc_auc {type: number}
# }

# view: roc_curve {
#   derived_table: {
#     sql: SELECT * FROM ml.ROC_CURVE(
#         MODEL ${future_purchase_model.SQL_TABLE_NAME},
#         (SELECT * FROM ${testing_input.SQL_TABLE_NAME}));;
#   }
#   dimension: threshold {
#     type: number
#     value_format_name: decimal_4
#     link: {
#       label: "Campaign List Creator"
#       url: "/dashboards/202?Customer%20Propensity%20to%20Purchase=>{{ rendered_value | encode_uri }}"
#       icon_url: "http://www.looker.com/favicon.ico"
#     }


#   }
#   dimension: recall {type: number value_format_name: percent_2}
#   dimension: false_positive_rate {type: number}
#   dimension: true_positives {type: number }
#   dimension: false_positives {type: number}
#   dimension: true_negatives {type: number}
#   dimension: false_negatives {type: number }
#   dimension: precision {
#     type:  number
#     value_format_name: percent_2
#     sql:  ${true_positives} / NULLIF((${true_positives} + ${false_positives}),0);;
#     description: "Equal to true positives over all positives. Indicative of how false positives are penalized. Set high to get no false positives"
#   }
#   measure: total_false_positives {
#     type: sum
#     sql: ${false_positives} ;;
#   }
#   measure: total_true_positives {
#     type: sum
#     sql: ${true_positives} ;;
#   }
#   dimension: threshold_accuracy {
#     type: number
#     value_format_name: percent_2
#     sql:  1.0*(${true_positives} + ${true_negatives}) / NULLIF((${true_positives} + ${true_negatives} + ${false_positives} + ${false_negatives}),0);;
#   }
#   dimension: threshold_f1 {
#     type: number
#     value_format_name: percent_3
#     sql: 2.0*${recall}*${precision} / NULLIF((${recall}+${precision}),0);;
#   }
# }

# ########################################## PREDICT FUTURE ############################
# view: future_input {
#   derived_table: {
#     explore_source: ga_sessions {
#       column: visitId {}
#       column: fullVisitorId {}
#       column: medium { field: trafficSource.medium }
#       column: channelGrouping {}
#       column: isMobile { field: device.isMobile }
#       column: country { field: geoNetwork.country }
#       column: bounces_total { field: totals.bounces_total }
#       column: pageviews_total { field: totals.pageviews_total }
#       column: transactions_count { field: totals.transactions_count }
#       column: first_time_visitors {}
# #       filters: {
# #         field: ga_sessions.partition_date
# #         value: "600 days"
# #       }
#     }
#   }
# }


# view: future_purchase_prediction {
#   derived_table: {
#     sql: SELECT * FROM ml.PREDICT(
#           MODEL ${future_purchase_model.SQL_TABLE_NAME},
#           (SELECT * FROM ${future_input.SQL_TABLE_NAME}));;
#   }
#   dimension: predicted_will_purchase_in_future {
#     type: number
#     description: "Binary classification based on max predicted value"
#   }
#   dimension: predicted_will_purchase_in_future_probability {
#     value_format_name: percent_2
#     type: number
#     sql:  ${TABLE}.predicted_will_purchase_in_future_probs[ORDINAL(1)].prob;;
#   }
#   dimension: visitId {type: number hidden:yes}
#   dimension: fullVisitorId {type: number hidden: yes}
#   measure: max_predicted_score {
#     type: max
#     value_format_name: percent_2
#     sql: ${predicted_will_purchase_in_future_probability} ;;
#   }
#   measure: average_predicted_score {
#     type: average
#     value_format_name: percent_2
#     sql: ${predicted_will_purchase_in_future_probability} ;;
#   }

#   # parameters to allow for dynamic inputs on User Finder dashboard

#   parameter: campaign_cost_per_recipient {
#     description: "Enter estimated cost per recipient for targeted campaign in USD"
#     type: number
#     default_value: "0.75"
#     allowed_value: {
#       label: "$0.25"
#       value: "0.25"
#     }
#     allowed_value: {
#       label: "$0.50"
#       value: "0.50"
#     }
#     allowed_value: {
#       label: "$0.75"
#       value: "0.75"
#     }
#     allowed_value: {
#       label: "$1.00"
#       value: "1.00"
#     }
#     allowed_value: {
#       label: "$1.25"
#       value: "1.25"
#     }
#   }

#   measure: estimated_campaign_cost_per_recipient {
#     label:"Est. Campaign Cost per Recipient"
#     type: max
#     sql: {% parameter campaign_cost_per_recipient %} ;;
#     value_format_name: usd
#   }

#   parameter: lifetime_revenue_per_customer {
#     description: "Enter estimated lifetime value per customer"
#     type: number
#     default_value: "150.00"
#     allowed_value: {
#       label: "$100"
#       value: "100.00"
#     }
#     allowed_value: {
#       label: "$125"
#       value: "125.00"
#     }
#     allowed_value: {
#       label: "$150"
#       value: "150.00"
#     }
#     allowed_value: {
#       label: "$175"
#       value: "175.00"
#     }
#     allowed_value: {
#       label: "$200"
#       value: "200.00"
#     }
#   }

#   measure: estimated_lifetime_revenue_per_customer {
#     label:"Est. Lifetime Revenue per Customer"
#     type: max
#     sql: {% parameter lifetime_revenue_per_customer %} ;;
#     value_format_name: usd
#   }

#   parameter: conversion_boost_from_campaign {
#     description: "Enter % increase in customer acquisition as a result of targeted campaign"
#     type: number
#     default_value: "0.30"
#     allowed_value: {
#       label: "10.0%"
#       value: "0.10"
#     }
#     allowed_value: {
#       label: "20.0%"
#       value: "0.20"
#     }
#     allowed_value: {
#       label: "30.0%"
#       value: "0.30"
#     }
#     allowed_value: {
#       label: "40.0%"
#       value: "0.40"
#     }
#     allowed_value: {
#       label: "50.0%"
#       value: "0.50"
#     }
#   }

#   measure: estimated_conversion_boost_from_campaign {
#     label:"Est. Conversion Boost from Campaign"
#     type: max
#     sql: {% parameter conversion_boost_from_campaign %} ;;
#     value_format_name: percent_1
#   }
# }

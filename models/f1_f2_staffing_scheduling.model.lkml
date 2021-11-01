connection: "gcp_hca_poc"

# include all the views
include: "/views/**/*.view"

datagroup: f1_f2_staffing_scheduling_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: f1_f2_staffing_scheduling_default_datagroup

### 1. Raw Data

explore: staffing_volume_predictions_1_load_raw_data {
  hidden: yes
}

### 2. Model Inputs

explore: volume_by_facility_by_shift_by_day {}

### 3. BQML

explore: volume_model_training_info {
  label: "BQML - 1 - Training Info"
}
explore: volume_model_evaluation {
  label: "BQML - 2 - Evaluation"
}
explore: volume_model_ml_weights {
  label: "BQML - 3 - ML Weights"
}
explore: volume_prediction {
  label: "BQML - 4 - Predictions"
}

############ Caching Logic ############

persist_with: new_data

### PDT Timeframes

datagroup: new_data {
  max_cache_age: "30 minutes"
  sql_trigger: SELECT max(measurement_timestamp) FROM `staffing_scheduling.staffing_volume_predictions_1_load_raw_data` ;;
}

datagroup: once_daily {
  max_cache_age: "24 hours"
  sql_trigger: SELECT current_date() ;;
}

datagroup: once_weekly {
  max_cache_age: "168 hours"
  sql_trigger: SELECT extract(week from current_date()) ;;
}

datagroup: once_monthly {
  max_cache_age: "720 hours"
  sql_trigger: SELECT extract(month from current_date()) ;;
}

datagroup: once_yearly {
  max_cache_age: "9000 hours"
  sql_trigger: SELECT extract(year from current_date()) ;;
}

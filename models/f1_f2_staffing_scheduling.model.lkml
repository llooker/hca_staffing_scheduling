# connection: "gcp_hca_poc"
connection: "hca_hack_poc"

# include all the views
include: "/views/**/*.view"
include: "/bqml_model/**/*.view"
include: "/registration_data/**/*.view"

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

explore: volume_by_facility_by_shift_by_day {

  join: median_calc {
    relationship: one_to_one
    sql_on: ${volume_by_facility_by_shift_by_day.pk} = ${median_calc.pk} ;;
  }

  join: volume_prediction {
    relationship: one_to_one
    sql_on: ${volume_by_facility_by_shift_by_day.pk} = ${volume_prediction.pk} ;;
  }

  join: summary_predictions {
    relationship: one_to_one
    sql_on: ${volume_by_facility_by_shift_by_day.pk} = ${summary_predictions.pk} ;;
  }

  # join: staffing_volume_predictions_1_load_raw_data {
  #   relationship: one_to_many
  #   sql_on:
  #         ${volume_by_facility_by_shift_by_day.coid_department} = ${staffing_volume_predictions_1_load_raw_data.coid_department}
  #     AND ${volume_by_facility_by_shift_by_day.shift} = ${staffing_volume_predictions_1_load_raw_data.shift}
  #     AND ${volume_by_facility_by_shift_by_day.census_date} = ${staffing_volume_predictions_1_load_raw_data.census_date}
  #   ;;
  # }

  join: facility_master {
    relationship: many_to_one
    sql_on: ${volume_by_facility_by_shift_by_day.coid} = ${facility_master.coid};;
  }
}

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

#### Registration Data

explore: registration_to_admission_hours {
  hidden: yes
}

explore: hourly_census {
  join: count_pre_registrations_by_date_yesterday {
    from: count_pre_registrations_by_date
    relationship: one_to_one
    type: inner
    sql_on:
          ${hourly_census.coid} = ${count_pre_registrations_by_date_yesterday.coid}
      AND ${hourly_census.census_date} = date_add(${count_pre_registrations_by_date_yesterday.pre_registration_date}, interval 1 day)
    ;;
  }

  join: count_pre_registrations_by_date_today {
    from: count_pre_registrations_by_date
    relationship: one_to_one
    type: inner
    sql_on:
          ${hourly_census.coid} = ${count_pre_registrations_by_date_today.coid}
      AND ${hourly_census.census_date} = ${count_pre_registrations_by_date_today.pre_registration_date}
    ;;
  }
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

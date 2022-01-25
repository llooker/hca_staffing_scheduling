include: "/2021_10_hack_demand_forecasting/**/*.view"

view: hourly_census {
  extends: [staffing_volume_predictions_1_load_raw_data]
}




#   sql_table_name: `hca-cti-ds-hackathon.f1_f2_staffing_scheduling.hourly_census`
#     ;;

#   dimension: beds_in_service_cnt {
#     type: number
#     sql: ${TABLE}.Beds_In_Service_Cnt ;;
#   }

#   dimension: beginning_census_cnt {
#     type: number
#     sql: ${TABLE}.Beginning_Census_Cnt ;;
#   }

#   dimension_group: census {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}.Census_Date ;;
#   }

#   dimension_group: census_date_hour {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}.Census_Date_Hour ;;
#   }

#   dimension: coid {
#     type: number
#     value_format_name: id
#     sql: ${TABLE}.Coid ;;
#   }

#   dimension: coid_name {
#     type: string
#     sql: ${TABLE}.COID_Name ;;
#   }

#   dimension: default_dept_num {
#     type: number
#     sql: ${TABLE}.Default_Dept_Num ;;
#   }

#   dimension: discharge_cnt {
#     type: number
#     sql: ${TABLE}.Discharge_Cnt ;;
#   }

#   dimension: division_name {
#     type: string
#     sql: ${TABLE}.Division_Name ;;
#   }

#   dimension: expired_patient_cnt {
#     type: number
#     sql: ${TABLE}.Expired_Patient_Cnt ;;
#   }

#   dimension: facility_mnemonic_cs {
#     type: string
#     sql: ${TABLE}.Facility_Mnemonic_CS ;;
#   }

#   dimension: group_name {
#     type: string
#     sql: ${TABLE}.Group_Name ;;
#   }

#   dimension: location_active_ind {
#     type: yesno
#     sql: ${TABLE}.Location_Active_Ind ;;
#   }

#   dimension: location_code {
#     type: string
#     sql: ${TABLE}.Location_Code ;;
#   }

#   dimension: location_desc {
#     type: string
#     sql: ${TABLE}.Location_Desc ;;
#   }

#   dimension: location_mnemonic {
#     type: string
#     sql: ${TABLE}.Location_Mnemonic ;;
#   }

#   dimension: location_type_code {
#     type: string
#     sql: ${TABLE}.Location_Type_Code ;;
#   }

#   dimension: market_name {
#     type: string
#     sql: ${TABLE}.Market_Name ;;
#   }

#   dimension: network_mnemonic_cs {
#     type: string
#     sql: ${TABLE}.Network_Mnemonic_CS ;;
#   }

#   dimension: nomenclature_code {
#     type: string
#     sql: ${TABLE}.Nomenclature_Code ;;
#   }

#   dimension: observation_discharge_cnt {
#     type: number
#     sql: ${TABLE}.Observation_Discharge_Cnt ;;
#   }

#   dimension: observation_expired_patient_cnt {
#     type: number
#     sql: ${TABLE}.Observation_Expired_Patient_Cnt ;;
#   }

#   dimension: observation_transfer_in_cnt {
#     type: number
#     sql: ${TABLE}.Observation_Transfer_In_Cnt ;;
#   }

#   dimension: observation_transfer_out_cnt {
#     type: number
#     sql: ${TABLE}.Observation_Transfer_Out_Cnt ;;
#   }

#   dimension: transfer_in_cnt {
#     type: number
#     sql: ${TABLE}.Transfer_In_Cnt ;;
#   }

#   dimension: transfer_out_cnt {
#     type: number
#     sql: ${TABLE}.Transfer_Out_Cnt ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [coid_name, division_name, market_name, group_name]
#   }
# }

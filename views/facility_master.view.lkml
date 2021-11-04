view: facility_master {
  sql_table_name:
  (
    SELECT a.*
    FROM `hca-cti-ds-hackathon.f1_f2_staffing_scheduling.facility_master` a
    INNER JOIN
    (
      SELECT coid, min(geographic_latitude_num) as min_lat
      FROM `hca-cti-ds-hackathon.f1_f2_staffing_scheduling.facility_master`
      GROUP BY 1
    ) b
      ON a.coid = b.coid
      AND a.geographic_latitude_num = b.min_lat
  )
    ;;
  # `hca-cti-ds-hackathon.f1_f2_staffing_scheduling.facility_master`

  dimension: building_code {
    type: string
    sql: ${TABLE}.Building_Code ;;
  }

  dimension: city_name {
    type: string
    sql: ${TABLE}.City_Name ;;
  }

  dimension: coid {
    type: number
    value_format_name: id
    sql: ${TABLE}.COID ;;
  }

  dimension: country_code {
    type: string
    sql: ${TABLE}.Country_Code ;;
  }

  dimension: county_name {
    type: string
    sql: ${TABLE}.County_Name ;;
  }

  dimension: geographic_latitude_num {
    type: number
    sql: ${TABLE}.Geographic_Latitude_Num ;;
  }

  dimension: geographic_longitude_num {
    type: number
    sql: ${TABLE}.Geographic_Longitude_Num ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${geographic_latitude_num} ;;
    sql_longitude: ${geographic_longitude_num} ;;
  }

  dimension: operating_status_code {
    type: string
    sql: ${TABLE}.Operating_Status_Code ;;
  }

  dimension: operating_status_name {
    type: string
    sql: ${TABLE}.Operating_Status_Name ;;
  }

  dimension: parent_site_code {
    type: string
    sql: ${TABLE}.Parent_Site_Code ;;
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}.Postal_Code ;;
  }

  dimension: site_code {
    type: string
    sql: ${TABLE}.Site_Code ;;
  }

  dimension: site_name {
    type: string
    sql: ${TABLE}.Site_Name ;;
  }

  dimension: site_short_name {
    type: string
    sql: ${TABLE}.Site_Short_Name ;;
  }

  dimension: site_type {
    type: string
    sql: ${TABLE}.Site_Type ;;
  }

  dimension: state_code {
    type: string
    sql: ${TABLE}.State_Code ;;
  }

  dimension: street_addr_1 {
    type: string
    sql: ${TABLE}.Street_Addr_1 ;;
  }

  dimension: street_addr_2 {
    type: string
    sql: ${TABLE}.Street_Addr_2 ;;
  }

  dimension: time_zone_code {
    type: string
    sql: ${TABLE}.Time_Zone_Code ;;
  }

  dimension: time_zone_name {
    type: string
    sql: ${TABLE}.Time_Zone_Name ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      site_short_name,
      county_name,
      city_name,
      site_name,
      operating_status_name,
      time_zone_name
    ]
  }
}

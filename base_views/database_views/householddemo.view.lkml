#############################
##13/02/2020
##TF
#############################

view: householddemo {
  sql_table_name: "CORE"."HOUSEHOLDDEMOINTERNATIONAL"     --SDR 18/03/2020
    ;;

view_label: "Demographic Information"

  #########################################################################

  dimension: accountholderagegroup {
    type: string
    sql: ${TABLE}."ACCOUNTHOLDERAGEGROUP" ;;
    label: "Account Holder Age Group"
    group_label: "Account Holder"
  }

  dimension: accountholdergender {
    type: string
    sql: ${TABLE}."ACCOUNTHOLDERGENDER" ;;
    label: "Account Holder Gender"
    group_label: "Account Holder"
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
#     group_label: "Account Holder"
#     label: "Country"
    hidden: yes

  }

#   dimension: countrynameformaps {
#     type: string
#     map_layer_name: countries
#     sql: CASE WHEN ${TABLE}."COUNTRY" = 'UK' THEN 'GB' ELSE  ${TABLE}."COUNTRY" END;;
#     group_label: "Account Holder"
#     label: "Country"
#     hidden:  yes
#   }
# TF01
##SDR 18/03/2020 hidden to avoid confusion
#####################################################

  dimension: has16_to34 {
    type: yesno
    sql: ${TABLE}."HAS16TO34" =1;;
    label: "Has 16-34 Occupants"
    group_label: "Demos"
  }

  dimension: has16_to44 {
    type: yesno
    sql: ${TABLE}."HAS16TO44" =1;;
    label: "Has 16-44 Occupants"
    group_label: "Demos"
  }
  dimension: haskids {
    type: yesno
    sql: ${TABLE}."HASKIDS" =1;;
    label: "Has Kids"
    group_label: "Demos"
  }

  dimension: kidsgroup {
    type: string
    sql: case when ${TABLE}."KIDSGROUP"='HasKids' then '0-15' else ${TABLE}."KIDSGROUP" end ;;
    label: "Kids Age Group"
    group_label: "Demos"
    hidden: yes
  }

  dimension: sec {
    type: string
    sql: ${TABLE}."SEC" ;;
    label: "SEC"
    group_label: "Demos"
  }

  dimension: secgroup {
    type: string
    sql: ${TABLE}."SECGROUP" ;;
    label: "SEC Group"
    group_label: "Demos"
  }

  dimension: householdsize {
    type: number
    sql: ${TABLE}."HOUSEHOLDSIZE" ;;
    label: "Size of Household"      ##SDR 18/03/2020 removed "yes/no"
    group_label: "Demos"
  }

  ###############################################
  dimension: hasbt {
    type: yesno
    sql: ${TABLE}."HASBT" =1;;
    label: "Has BT"
    group_label: "Media Platforms"
    hidden: yes
  }

  dimension: hasfreeview {
    type: yesno
    sql: ${TABLE}."HASFREEVIEW" =1;;
    label: "Has Freeview"
    group_label: "Media Platforms"
    hidden: yes
  }

  dimension: hasother {
    type: yesno
    sql: ${TABLE}."HASOTHER" =1;;
    label: "Has Other TV Platform"
    group_label: "Media Platforms"
    hidden: yes
  }

  dimension: hasprime {
    type: yesno
    sql: ${TABLE}."HASPRIME" =1;;
    label: "Has Amazon Prime"
    group_label: "Media Platforms"
  }

  dimension: hassky {
    type: yesno
    sql: ${TABLE}."HASSKY" =1;;
    label: "Has Sky"
    group_label: "Media Platforms"
    hidden: yes
  }

  dimension: hasvirgin {
    type: yesno
    sql: ${TABLE}."HASVIRGIN" =1;;
    label: "Has Virgin Media"
    group_label: "Media Platforms"
    hidden: yes
  }

  dimension: housholdplatform {
    type: string
    sql: ${TABLE}."HOUSHOLDPLATFORM" ;;
    label: "Primary Household Platform"
    group_label: "Media Platforms"
  }

  dimension: rid {
    type: number
    value_format_name: id
    sql: ${TABLE}."RID" ;;
    #primary_key: yes
    view_label: "Demographic Information"
    group_label: "Account Holder"
    label: "Household ID"
#     hidden: yes
  }

  dimension: ridkey {
    type: string
    primary_key: yes
    hidden: yes
  }

########################################################################



  dimension: demoid {
    type: number
    value_format_name: id
    sql: ${TABLE}."DEMOID" ;;
    hidden: yes
  }

    dimension: churnedoffquarter {
    type: string
    sql: ${TABLE}."CHURNEDOFFQUARTER" ;;
    hidden: yes
  }

}

#######################
##TF
##March 2020
#######################

view: internationalweights {
  sql_table_name: "CORE"."INTERNATIONALWEIGHTS"
    ;;

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
    hidden: yes
  }

  dimension: panelquarter {
    type: number
    sql: ${TABLE}."PANELQUARTER" ;;
    hidden: yes
  }

  dimension: panelyear {
    type: number
    sql: ${TABLE}."PANELYEAR" ;;
    hidden: yes
  }

  dimension: rid {
    type: number
    value_format_name: id
    sql: ${TABLE}."RID" ;;
    hidden: yes
  }

  dimension: thousandsweight {
    type: number
    sql: ${TABLE}."WEIGHTING" ;;
    hidden: yes
  }

}

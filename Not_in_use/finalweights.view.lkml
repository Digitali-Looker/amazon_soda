#############################
##13/02/2020
##TF
#############################

view: finalweights {
  sql_table_name: "CORE"."FINALWEIGHTS"
    ;;

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
    hidden: yes
  }

  dimension: demoid {
    type: number
    value_format_name: id
    sql: ${TABLE}."DEMOID" ;;
    hidden: yes
  }

  dimension: finalweight {
    type: number
    sql: ${TABLE}."FINALWEIGHT" ;;
    hidden: yes
  }

  dimension: multiplier {
    type: number
    sql: ${TABLE}."MULTIPLIER" ;;
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

  dimension: thousandsweight {
    type: number
    sql: ${TABLE}."THOUSANDSWEIGHT" ;;
    hidden: yes
  }

  dimension: weight {
    type: number
    sql: ${TABLE}."WEIGHT" ;;
    hidden: yes
  }

  dimension: pk {
    type: string
    sql: concat(${demoid},${panelyear},${panelquarter},${country}) ;;
    primary_key:  yes
    hidden: yes
  }


}

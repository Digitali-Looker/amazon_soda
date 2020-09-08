view: cliptrailerflag {
  sql_table_name: "CORE"."CLIPTRAILERFLAG"
  ;;


  dimension: diid {
    sql: ${TABLE}.DIID ;;
    type: number
    hidden: yes
    primary_key: yes
  }

  dimension: clipflag {
    sql: ${TABLE}.CLIPFLAG ;;
    type: yesno
    hidden: yes
  }

  dimension: trailerflag {
    sql: ${TABLE}.TRAILERFLAG ;;
    type: yesno
    hidden: yes
  }

}

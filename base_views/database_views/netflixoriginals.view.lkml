#############################
##13/02/2020
##TF
#############################

view: netflixoriginals {
  sql_table_name: "CORE"."NETFLIXORIGINALS"
      ;;

  dimension: netflixid {
    type: string
    sql: ${TABLE}."NETFLIXID" ;;
    primary_key: yes
    hidden: yes
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
    hidden: yes
  }

dimension: IsNetflixOriginal {
  type: yesno
#   sql:  case when ${netflixid} is not null then 1 end;;
sql: ${netflixid} IS NOT NULL ;;
  view_label: "Content Selection"
  group_label: "Content"
  label: "Is Netflix Original"
  hidden: yes
}

dimension: IsNetflixOriginalFullName {
  type: string
  sql: case when ${IsNetflixOriginal} ='yes' then 'Netflix Original' else 'Acquired Content' end ;;
  view_label: "Content Selection"
  group_label: "Content"
  label: "Is Netflix Original"
  hidden: yes   ##SDR 18/08/2020
}


}

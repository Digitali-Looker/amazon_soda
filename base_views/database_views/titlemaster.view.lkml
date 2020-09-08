#############################
##13/02/2020
##TF
#############################

view: titlemaster {
  sql_table_name: "CORE"."TITLEMASTER"
    ;;

    view_label: "Content Selection"

  #########################################################################

    dimension: videotype {
      group_label: "Content"
    label: "Content Type (Movie/Series)"
    type: string
     sql: CASE WHEN TRIM(${TABLE}."VIDEOTYPE") = 1 THEN 'Movie' WHEN TRIM(${TABLE}."VIDEOTYPE") = 2 THEN 'Series' END ;;
  }

  dimension: netflixid {
    type: string
    value_format_name: id
    sql: ${TABLE}."NETFLIXID" ;;
#     hidden: yes
    group_label: "Content"
    label: "Netflix ID"
  }
  #########################################################################

  dimension: dateadded {
    type: string
    sql: ${TABLE}."DATEADDED" ;;
    hidden: yes
  }

  dimension: episodeid {
    type: string
    value_format_name: id
    # hidden: yes
    sql: ${TABLE}."EPISODEID" ;;
    hidden: yes
  }



  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
#     view_label: "Content Selection"
#     label: "TEST TITLE"
     hidden: yes
  }

  dimension: titleid {
    type: number
    value_format_name: id
    sql: ${TABLE}."TITLEID" ;;
    hidden: yes
    primary_key: yes
  }

}

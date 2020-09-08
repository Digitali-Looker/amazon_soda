#############################
##13/02/2020
##TF
#############################

view: titlegenres {
  sql_table_name: "CORE"."TITLEGENRES"
    ;;

  dimension: genre {
    type: string
    sql: ifnull(${TABLE}."GENRE",'Other') ;;
    view_label: "Content Selection"
    group_label: "Genre"
    label: "Non-Unique Genre"
    description: "This shows the multiple genres assigned to this title, e.g. Comedy/ Other"
#     hidden: yes
  }

  dimension: netflixid {
    type: number
    value_format_name: id
    sql: ${TABLE}."NETFLIXID" ;;
    hidden: yes
  }

#     measure:  rankedstreams{
#     type: number
#     sql:  row_number() OVER(PARTITION BY ${titlegenres.genre} order by ${paneldata.dim_streams} desc) ;;
#   }


#   dimension: is_top_10 {
#     type: yesno
#     sql:
#     exists(
#       select *
#       from (
#         select genre
#         from core.titlegenres
#         group by genre
#         order by ${paneldata.dim_streams} desc
#         limit 10
#       ) top_10
#     ) ;;
#   }

#   dimension: dim_rankedstreams {
#     type: number
#     sql:  row_number() OVER(PARTITION BY ${titlegenres.genre} order by ${paneldata.dim_streams} desc) ;;
#   }
#   dimension: rankedstreamstop5 {
#     type: number
#     sql: case when ${dim_rankedstreams} between 1 and 5 then 1 else 0 end ;;
#   }


}

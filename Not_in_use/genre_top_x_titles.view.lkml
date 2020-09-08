###################################
##SDR
##20/02/2020
###################################

view: genre_top_x_titles {
  derived_table: {
    sql: WITH genre_CTE AS
      (
      SELECT
        ifnull(titlegenres."GENRE",'Other')  AS genre,
        titlemaster."NETFLIXID"  AS netflixid,
        contentmaster."TITLE"  AS title,
        COALESCE(SUM((finalweights."THOUSANDSWEIGHT")  ), 0) AS streams,
        row_number() OVER(PARTITION BY (ifnull(titlegenres."GENRE",'Other')) order by (sum((finalweights."THOUSANDSWEIGHT"))) desc)  AS rankedstreams
      FROM "CORE"."PANELDATA"
           AS paneldata
      LEFT JOIN "CORE"."TITLEMASTER"
           AS titlemaster ON (paneldata."TITLEID") = (titlemaster."TITLEID")
      LEFT JOIN "CORE"."CONTENTMASTER"
           AS contentmaster ON (contentmaster."NETFLIXID") = (titlemaster."NETFLIXID")
      LEFT JOIN "CORE"."HOUSEHOLDDEMO"
           AS householddemo ON (paneldata."RESPONDANTID") = (householddemo."RID")
              and (paneldata."COUNTRY") = (householddemo."COUNTRY")
      LEFT JOIN "CORE"."FINALWEIGHTS"
           AS finalweights ON (finalweights."DEMOID")= (householddemo."DEMOID")
             and year((paneldata."DATE")) = (finalweights."PANELYEAR")
             and QUARTER((paneldata."DATE")) = (finalweights."PANELQUARTER")
             and (paneldata."COUNTRY") = (finalweights."COUNTRY")
      LEFT JOIN "CORE"."TITLEGENRES"
           AS titlegenres ON (contentmaster."NETFLIXID") = (titlegenres."NETFLIXID")
--      LEFT JOIN "CORE"."NETFLIXORIGINALS" as netflixoriginals
 --     ON netflixoriginals.netflixid = titlemaster.netflixid
      WHERE (titlemaster."NETFLIXID") is not null

      GROUP BY 1,2,3
      )
      SELECT *,         sum(streams) OVER(PARTITION BY genre) as subtotal
      FROM genre_CTE
      WHERE rankedstreams BETWEEN 1 AND 5
      ORDER BY genre, rankedstreams
       ;;
  }
  view_label: "Genre top 5 Titles"
#       and {%condition IsNetflixOriginal %} netflixoriginals {%endcondition%}
  ########################################################################
  ##dimensions and parameters
  ########################################################################

#   parameter: genretreamsrank {
#     type: number
#     default_value: "5"
#   }

 dimension:  pk{
   sql: concat(${genre}, ${netflixid}) ;;
  primary_key: yes
  hidden: yes
 }

  dimension: genre {
    type: string
    sql: ${TABLE}."GENRE" ;;
#     hidden: yes
  }

  dimension: netflixid {
    type: string
    sql: ${TABLE}."NETFLIXID" ;;
#     hidden: yes
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
#     hidden: yes
  }

  dimension: streams {
    type: number
    sql: ${TABLE}."STREAMS" ;;
    hidden: yes
    value_format: "#,##0"
  }

  measure: measure_streams {
    type: sum
    sql: ${streams}  ;;
    value_format: "#,##0"
    }

#     dimension: subtotal {
#       type: number
#       sql: sum(streams) over(partition by ${genre}) ;;
#     }

    dimension: subtotal {
      type: number
      sql: ${TABLE}."SUBTOTAL";;
    }

  dimension: rankedstreams {
    type: number
    sql: ${TABLE}."RANKEDSTREAMS" ;;
#     order_by_field: rankedstreams
#     hidden: yes
  }

}

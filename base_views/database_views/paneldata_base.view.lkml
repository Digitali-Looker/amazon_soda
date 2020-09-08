#############################
##14/02/2020
##SDR
#############################

view: paneldata_base {
  sql_table_name: "CORE"."PANELDATAINTERNATIONAL"
    ;;
  ##  view_label: "Panel Information (Demo and Activity)"

  #####################################################################



  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
    view_label: "Activity Timeframe Selection"
    group_label: "Activity Timeframe"
    label: "Activity"
    description: "Please only use Activity Date for filtering to ensure correct calculations!"

  }




  #####################################################################
  ##Measures
  ##These are universal basic measures that won't differ by type of explore used and wouldn't require any separation => they can stay within base explore
  ##!!!!!!!!!!!!Remember, when referencing anything from this view, you need to reference a respective extension instead!!!!!!!!!!!!!!!!!!
  ## Example: instead of ${paneldata.streams} use ${ext_paneldata_fce.streams} or ${paneldata.streams}!!!!!!!!!!!!!!!!!!!!!!!

  measure: streams {
    label: "Streams (000s)"

    type: sum
    #sql: ${finalweights.thousandsweight}  ;; TF04 Changed to look at internationalweights instead
    sql: ${internationalweights.thousandsweight}  ;;
    view_label: "Measures"
    group_label: "Streams"
    value_format: "#,##0"
  }


  measure: percent_of_total_streams {
    type: percent_of_total
    direction: "column"
    sql: ${streams} ;;
    view_label: "Measures"
    group_label: "Streams"
    label: "Percent of Total Streams in Selection (%)"
    value_format: "0.0\%"
#     description: "This will give you a 'Percent Of Total' figure; e.g. bring in a title and season number to then see what percent of the total streams for the title each season number comprises"
    #description: "This will calculate a cell’s portion of the column total of streams (000s). The % is calculated against the total of the rows returned by the query, and not the total of all possible rows. However, if the data returned by the query exceeds a row limit, the field’s values will appear as nulls, since it needs the full results to calculate the percent of total"
  description: "Total is calculated based on the filtered subset of data"
  }##SDR 020320- added in a little description

  measure: running_total_streams {
    label: "Running Total of Streams in Selection (000s)"
    type: running_total
    direction: "column"
    sql: ${streams} ;;
    view_label: "Measures"
    group_label: "Streams"
    value_format: "#,##0"
    #description: "This will show you a running total of streams in your selection; e.g. bring in a title and season number to then see the total streams accumulated over the number of seasons."
  description: "Running total is performed depending on the sorting in the table"
  }##SDR 020320- added in a little description


  ######################################################################

  dimension: diid {
    type: number
    value_format_name: id
    sql: ${TABLE}."DIID" ;;
    hidden: yes
    primary_key: yes
  }

  measure: count_sessions {
    type: count_distinct
    sql: ${diid} ;;
    hidden: yes
  }

  dimension: filename {
    type: string
    sql: ${TABLE}."FILENAME" ;;
    hidden: yes
  }

  dimension: filenumber {
    type: string
    sql: ${TABLE}."FILENUMBER" ;;
    hidden: yes
  }

  dimension: netflixprofileid {
    type: number
    value_format_name: id
    sql: ${TABLE}."NETFLIXPROFILEID" ;;
    view_label: "Demographic Information"
    group_label: "Account Holder"
    label: "Profile ID"

#     hidden: yes
  }

  dimension: personkey {
    type: string
    sql: ${TABLE}."PERSONKEY" ;;
    hidden: yes
  }

  dimension: quarterload {
    type: string
    sql: ${TABLE}."QUARTERLOAD" ;;
    hidden: yes
  }

  dimension: respondantid {
    type: number
    value_format_name: id
    sql: ${TABLE}."RESPONDANTID" ;;
    hidden: yes
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
    hidden: yes
  }

  dimension: titleid {
    type: number
    value_format_name: id
    sql: ${TABLE}."TITLEID" ;;
    hidden: yes
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
    hidden: yes

  }

  dimension: rid_country {
    type: string
    sql: ${respondantid}||${country} ;;
    hidden: yes
  }

  dimension: countrynameformaps {
    type: string
    map_layer_name: countries
    sql: CASE WHEN ${country} = 'UK' THEN 'United Kingdom' ELSE  ${country} END;;   ##SDR 18/03/2020 trialling for visuals
    view_label: "Demographic Information"
    group_label: "Account Holder"
    label: "Country"
    suggest_persist_for: "10 seconds"

  }
    #TF01

###########################################################################################################################
###########################################################################################################################
###########################################################################################################################
###########################################################################################################################
##OLD SCRIPTS, NOT IN USE

  #############################################################
  ##Days Since

#     measure: datefirstviewedinperiodselected {
#       type: date
#       sql: min(${date_raw}) ;;
#       view_label: "Activity Timeframe Selection"
#       label: "Date First Viewed In Period Selected"
#     }
#
#     dimension_group: dayssincedatefirstviewedinperiodselected {
#       type: duration
#       intervals: [day]
#       sql_start: ${datefirstviewedinperiodselected};;
#       sql_end: ${date_raw} ;;
#     }



#   dimension_group: timesincedatefirstviewed {
#     type: duration
#     intervals: [day, week]
# #     sql_start: ${releasedate.datefirstviewed};;
#     sql_start: ${releasedate.datefirstviewed} ;;
#     sql_end: ${date_raw} ;;
#     view_label: "Activity Timeframe Selection"
#     group_label: "Days/ Weeks Since First Viewed"
#     label: "Since First Viewed"
#     description: "Use the [Greater than or Equal to] operator and enter the number of days/ weeks to see an activity time window (from when the content was first viewed plus x days/ weeks)"
#   }
## DS 05/03/20 Moved to the derived table so it can be duplicated and joined separately to client facing explore and dashboards explore


#   filter: timesincedatefirstviewedfilter {
#     type: number
# #     sql: {%condition timesincedatefirstviewedfilter%} ${days_timesincedatefirstviewed} {%endcondition%} ;;
#   }

  ###########################################################################################################################################
  ##dont need as the same as when the activity occurred!! actually do for weeks as otherwise repeating values! also wouldnt work as the query is trying to do a date_trunc which then shows the date as 2019-10 which then cant be added
#   dimension: dateofdayssincefirstviewed {
#     type: date
#     sql: {%if    days_timesincedatefirstviewed._in_query %}
#          DATEADD(DAY,${days_timesincedatefirstviewed}, ${releasedate.datefirstviewed})
#          {%elsif weeks_timesincedatefirstviewed._in_query %}
#           DATEADD(week,${weeks_timesincedatefirstviewed}, ${releasedate.datefirstviewed})
#
#         {%else%}
#         ${releasedate.datefirstviewed}
#         {%endif%}
#         ;;
#     view_label: "Activity Timeframe Selection"
#     label: "Days/ Weeks Since First Viewed Dates"
#     description: "Depending on your selection with days or weeks in the dimension 'Days / Weeks Since First Viewed', this will show the corresponding dates of the days/ weeks within that period"
# #     description: "Enter the number of days/ weeks after the content was first viewed by the panel to capture the activity within that Window"
#
#   }

#              {% elsif months_timesincedatefirstviewed._in_query %}
#         DATEADD(MONTH,${months_timesincedatefirstviewed}, ${releasedate.datefirstviewed})

#           {% elsif months_timesincedatefirstviewed._in_query %}
#          DATEADD(MONTH,${months_timesincedatefirstviewed}, ${releasedate.datefirstviewed})
##########################################################################################################################################


#   measure: streams_per_episode {
#     label: "Streams per Episode (000s)"
#     view_label: "Measures"
#     value_format: "#,##0"
#     description: "Use in conjunction with Number of Episodes"
#     sql: ${streams}/${numberofepisodes.noofepisodes} ;;
#   }
## DS 05/03/20 moved to the respective derived table so that it can be duped and joined separately to client explore and to dashboards explore (adding granularity params there)



}

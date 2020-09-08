include: "/*/*"


view: ext_paneldata_fce {

  extends: [paneldata_base]

#######################################################################################
##Parameters
#######################################################################################


  parameter: reachfrequency {
    type: string
    default_value: "1"
    view_label: "Frequency"
    label: "Reach Frequency Filter"
    description: "This is the least number of times a household has watched the criteria selected"
  }


  parameter: avg_reach_content_granularity {
    view_label: "Measures"
    group_label: "Granularity criteria for Average Measures: "
    group_item_label: "Content level"
    label: "Averaging criteria (Content level)"
    description: "This sets the level at which average measures (Reach or Streams) are calculated. If nothing is selected total figure based on selected filters will be shown. "
    type: unquoted
    default_value: "1"

    allowed_value: {
      label: "Title"
      value: "Title"
    }
    allowed_value: {
      label: "Season"
      value: "Season"
    }
    allowed_value: {
      label: "Episode"
      value: "Episode"
    }

  }

  parameter: avg_reach_date_granularity {
    view_label: "Measures"
    group_label: "Granularity criteria for Average Measures: "
    group_item_label: "Activity Timeframe level"
    label: "Averaging criteria (Activity Timeframe level)"
    description: "This sets the level at which average measures (Reach or Streams) are calculated. If nothing is selected total figure based on selected filters will be shown. "
    type: unquoted
    default_value: "1"

    allowed_value: {
      label: "Daily"
      value: "Daily"
    }
    allowed_value: {
      label: "Weekly"
      value: "Weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "Monthly"
    }
    allowed_value: {
      label: "Quarterly"
      value: "Quarterly"
    }
    allowed_value: {
      label: "Yearly"
      value: "Yearly"
    }

  }


#######################################################################################
##Measures
#######################################################################################

####################  Reach


  measure: reach {
    view_label: "Measures"
    group_label: "Reach"
    label: "Reach (000s)"
    description: "Number of unique accounts (000s) that watched content at least x times, x defined by Reach Frequency Filter"
    # description: "This returns the latest weights of the households who have watched the criteria brought into the query at least x times"
    type: sum
    sql: {% if NDT_reach.rowno._is_selected %} ${NDT_reach.thousandsweight} {% else %} case when ${NDT_reach.rowno} =  {%parameter reachfrequency %} then ${NDT_reach.thousandsweight} else 0 end {% endif %}

                             ;;
    value_format: "#,##0"
  }

  measure: reach_percent {
    view_label: "Measures"
    group_label: "Reach"
    label: "Reach %"
    description: "Reach (000s) as a % of filtered population, available breakdowns: by country, quarter and year"
    type: number
    value_format: "0.0\%"
    ##sql: ${reach}/${uni_size.filtered_population} ;;
    sql: (${reach}/${ext_paneldata_fce.dynamic_pop_size})*100 ;;
  }

####################  Average Reach


#   measure: avg_reach {
#     view_label: "Measures"
#     group_label: "Reach"
#     #label: "Average Reach (000s)"
#     #label_from_parameter: ndt_reach_dashboards.avg_reach_content_granularity
#     label: "Average {% if avg_reach_date_granularity._is_filtered %} {% parameter avg_reach_date_granularity %}  {%else%} {%endif%}
#     Reach (000s)
#     {% if avg_reach_content_granularity._is_filtered %} per {% parameter avg_reach_content_granularity %} {%else%} {%endif%} OLD"
#     description: "Average is calculated based on content level and/or activity timeframe level criteria selected"
#     #description: "This returns the average Reach of the households who have watched the criteria brought into the query at least x times, average is calculated based on content and/or date granularity criteria"
#     type: average_distinct
#     #sql: case when ${avg_rowno} =  {% parameter ndt_reach_dashboards.reachfrequency %} and ${select_rowno}=1 then ${sumreach} else null end  ;;
#     sql: case when  ${ndt_avg_reach.select_rowno}=1 then ${ndt_avg_reach.sumreach} else null end  ;;
# #     html: {% if {{rendered_value}} == ext_paneldata_fce.reach._rendered_value %} {{value| round: 0}} This is equal to Reach, please check your average parameter is set to a more detailed level the the breakdown in query!
# #           {% else %}
# #           {{value| round: 0}}
# #           {% endif %};;
#     value_format: "#,##0"
#     #######TO BE COMMENTED OUT
#   }



####################  Universe Size
#   measure: filtered_pop {
#     type: average
#     sql: ${uni_size.filtered_population} ;;
#     view_label: "Measures"
#     #hidden: yes
#   }


  measure: dynamic_pop_size {
    type: average
    sql: ${pop_size.dynamic}  ;;
    view_label: "Measures"
    label: "Population 000s"
    description: "Minimum granularity for population size is quarter filterable by demographic parameters, breakdown by demographic groups is not yet available"
    value_format: "#,##0"
  }


# ####################  Average Streams
#
#   dimension: noofitems_for_average {
#     view_label: "TEMP"
#     label: "Number of Items for Average"
#     type:  number
#     description: "Dynamically calculated number of episodes for each content level"
#     sql: case when ({% if avg_reach_content_granularity._parameter_value == 'Episode' %}
#          count (distinct ${title_lookup.titleseasonepisode_fce})
#          {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
#          count (distinct ${title_lookup.titleseason_fce})
#         {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
#         count (distinct ${title_lookup.titleonly_fce})
#         {%else%} 1
#         {%endif%})
#         > 0 then
#         {% if avg_reach_content_granularity._parameter_value == 'Episode' %}
#          count (distinct ${title_lookup.titleseasonepisode_fce})
#          {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
#          count (distinct ${title_lookup.titleseason_fce})
#         {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
#         count (distinct ${title_lookup.titleonly_fce})
#         {%else%} 1
#         {%endif%}
#         else 1 end
#
#         ;;
#     hidden: yes
# ###TO BE COMMENTED OUT
#
#   }
#
#
#   dimension: denominator_period {
#     label: "Content denominator"
#     view_label: "TEMP"
#     hidden: yes
#     type: number
#     sql: {% if avg_reach_date_granularity._parameter_value == 'Daily' %} count (distinct ${ext_paneldata_fce.date_date})
#       {% elsif avg_reach_date_granularity._parameter_value == 'Weekly' %} count (distinct ${ext_paneldata_fce.date_week})
#       {% elsif avg_reach_date_granularity._parameter_value == 'Monthly' %} count (distinct ${ext_paneldata_fce.date_month})
#       {% elsif avg_reach_date_granularity._parameter_value == 'Quarterly' %} count (distinct ${ext_paneldata_fce.date_quarter})
#       {% elsif avg_reach_date_granularity._parameter_value == 'Yearly' %} count (distinct ${ext_paneldata_fce.date_year})
#       {% else %} 1
#       {% endif %}
#       ;;
#       ##TO BE COMMENTED OUT
#
#     }
#
#
#     measure: avg_streams {
#       label: "Avg
#       {% if avg_reach_date_granularity._is_filtered %} {% parameter avg_reach_date_granularity %} {% else %} {% endif %}
#       Streams (000s)
#       {% if avg_reach_content_granularity._is_filtered %} per {% parameter avg_reach_content_granularity %} {% else %} {% endif %}
#       OLD"
#       description: "Average is calculated based on content level and/or activity timeframe level criteria selected"
#       view_label: "Measures"
#       group_label: "Streams"
#       value_format: "#,##0"
#       type: number
#       sql: ${ext_paneldata_fce.streams}/(${noofitems_for_average}*${denominator_period}) ;;
#       ##TO BE COMMENTED OUT
#     }


    dimension: datefirstviewed  {
      label: "Date First Viewed"
      view_label: "Content Selection"
      group_label: "Content"
      description: "Dynamic depending on if episode, season or title are included in the query"
      type: date
      sql: {%if episodes.episodenumber_IFNULL._in_query%}
         ${releasedate.mintitleseasonepisodedate}
         {%elsif episodes.seasonnumber_IFNULL._in_query%}
         ${releasedate.mintitleseasondate}
        {%else%}
         ${releasedate.mintitledate}
        {%endif%}
        ;;

      }


      filter: dayssincefirstviewed {
        type: number
        view_label: "Activity Timeframe Selection"
        label: "Days since First Viewed"
        description: "Use the [Less than or Equal to] operator and enter the number of days to see an activity time window (from when the content was first viewed plus x days)"  ##SDR 25/03/2020 removed weeks
        sql: {% condition dayssincefirstviewed %} ${days_timesincedatefirstviewed} {% endcondition %};;
      }

      dimension_group: timesincedatefirstviewed {
        type: duration
        intervals: [day, week]
#     sql_start: ${releasedate.datefirstviewed};;
        sql_start: ${ext_paneldata_fce.datefirstviewed::date} ;;
        sql_end: ${ext_paneldata_fce.date_raw} ;;
        view_label: "Activity Timeframe Selection"
        group_label: "Days/ Weeks Since First Viewed"
        label: "Since First Viewed"
#     description: "Use the [Less than or Equal to] operator and enter the number of days/ weeks to see an activity time window (from when the content was first viewed plus x days/ weeks)"
        hidden: yes
        can_filter: no
      }



####################  Dynamic Targeting


      measure: average_weight {
        type: average
        sql: ${internationalweights.thousandsweight} ;;
        hidden: yes
      }

############################ NEW AVERAGE REACH AND STREAMS CALCULATION




      dimension: average_denominator_new {
        view_label: "New Average Measures"
        label: "DENOMINATOR for average"
        type:  number
sql: count (distinct ${date_parameter_value}||${content_parameter_value}) ;;
hidden: yes
      }



      measure: avg_streams_new {
        label: "Average
        {% if avg_reach_date_granularity._is_filtered and avg_reach_date_granularity._parameter_value <> '1' %} {% parameter avg_reach_date_granularity %} {% else %} {% endif %}
        Streams (000s)
        {% if avg_reach_content_granularity._is_filtered and avg_reach_content_granularity._parameter_value <> '1' %} per {% parameter avg_reach_content_granularity %} {% else %} {% endif %}"
        description: "Average is calculated based on content level and/or activity timeframe level criteria selected"
        view_label: "Measures"
        group_label: "Streams"
        value_format: "#,##0"
        type: number
        sql: ${ext_paneldata_fce.streams}/${average_denominator_new} ;;
        html: {% if avg_reach_content_granularity._is_filtered and avg_reach_date_granularity._is_filtered %}
                    {% if (ext_paneldata_fce.content_inquery_check._value > ext_paneldata_fce.content_parameter_check._value) AND (ext_paneldata_fce.date_inquery_check._value > ext_paneldata_fce.date_parameter_check._value) %}
                    {{rendered_value}}
                    {% else %} {{rendered_value}} Please make sure your average granularity is more detailed than the breakdown in your data table
                    {% endif %}
              {% elsif avg_reach_content_granularity._is_filtered or avg_reach_date_granularity._is_filtered %}
                    {% if (ext_paneldata_fce.date_inquery_check._value > ext_paneldata_fce.date_parameter_check._value) or (ext_paneldata_fce.content_inquery_check._value > ext_paneldata_fce.content_parameter_check._value) %}
                    {{rendered_value}}
                    {% else %} {{rendered_value}} Please make sure your average granularity is more detailed than the breakdown in your data table
                    {% endif %}
              {% else %}
              Please make sure you have selected the criteria for average measures
              {% endif %};;
      }



      measure: avg_reach_new {
        view_label: "Measures"
        group_label: "Reach"
        label: "Average {% if avg_reach_date_granularity._is_filtered and avg_reach_date_granularity._parameter_value <> '1' %} {% parameter avg_reach_date_granularity %}  {%else%} {%endif%}
        Reach (000s)
        {% if avg_reach_content_granularity._is_filtered and avg_reach_content_granularity._parameter_value <> '1' %} per {% parameter avg_reach_content_granularity %} {%else%} {%endif%}"
        description: "Average is calculated based on content and/or date granularity selected. Please make sure you select at least one. "
        value_format: "#,##0"
        type: number
        sql: ( sum({% if NDT_reach.rowno._is_selected %} ${NDT_reach.thousandsweight} {% else %} case when ${NDT_reach.avg_rowno} =  {%parameter reachfrequency %} then ${NDT_reach.thousandsweight} else 0 end {% endif %}))
          /${average_denominator_new} ;;
#         html: {% if {{rendered_value}} == ext_paneldata_fce.reach._rendered_value %} {{value| round: 0}} This is equal to Reach, please check your average parameter is set to a more detailed level the the breakdown in query!
#               {% else %}
#               {{value| round: 0}}
#               {% endif %};;
        html: {% if avg_reach_content_granularity._is_filtered and avg_reach_date_granularity._is_filtered %}
                              {% if (ext_paneldata_fce.content_inquery_check._value > ext_paneldata_fce.content_parameter_check._value) AND (ext_paneldata_fce.date_inquery_check._value > ext_paneldata_fce.date_parameter_check._value) %}
                              {{rendered_value}}
                              {% else %} {{rendered_value}} Please make sure your average granularity is more detailed than the breakdown in your data table
                              {% endif %}
                        {% elsif avg_reach_content_granularity._is_filtered or avg_reach_date_granularity._is_filtered %}
                              {% if (ext_paneldata_fce.date_inquery_check._value > ext_paneldata_fce.date_parameter_check._value) or (ext_paneldata_fce.content_inquery_check._value > ext_paneldata_fce.content_parameter_check._value) %}
                              {{rendered_value}}
                              {% else %} {{rendered_value}} Please make sure your average granularity is more detailed than the breakdown in your data table
                              {% endif %}
                        {% else %}
                         Please make sure you have selected the criteria for average measures
              {% endif %};;
        }



        measure: noofepisodes_new {
          view_label: "Measures"
          ##group_label: "Content"
          label: "Number of Episodes"
          type:  number
          value_format: "#,##0"
          description: "Dynamically calculated number of episodes for each content level"
          sql: IFNULL(count (distinct ${title_lookup.titleseasonepisode_fce}),1)
            ;;
          can_filter: no
        }


#         filter: noofepisodes_global_filter_title {
#           type: number
#           view_label: "Content Selection"
#           label: "Global number of episodes in a title"
#           description: "This allows to filter by number of episodes, however this takes into account all available episodes within piece of content up to date (non date or country specific!). "
#           suggest_dimension: title_lookup.counttitlelevel
#           sql: {% condition noofepisodes_global_filter_title_season %} ${title_lookup.counttitlelevel} {% endcondition %};;
#         }
#
#
#
#         filter: noofepisodes_global_filter_title_season {
#           type: number
#           view_label: "Content Selection"
#           label: "Global number of episodes in a season"
#           description: "This allows to filter by number of episodes, however this takes into account all available episodes within piece of content up to date (non date or country specific!). "
#           suggest_dimension: title_lookup.countseasonlevel
#           sql: {% condition noofepisodes_global_filter_title_season %} ${title_lookup.countseasonlevel} {% endcondition %} ;;
#         }



        measure: date_parameter_check {
          type: number
          sql: {% if avg_reach_date_granularity._parameter_value == 'Daily' %}
                   1
                   {% elsif avg_reach_date_granularity._parameter_value == 'Weekly' %}
                   2
                  {% elsif avg_reach_date_granularity._parameter_value == 'Monthly' %}
                  3
                  {% elsif avg_reach_date_granularity._parameter_value == 'Quarterly' %}
                  4
                  {% elsif avg_reach_date_granularity._parameter_value == 'Yearly' %}
                  5
                  {%else%}
                  6
                  {%endif%} ;;
          hidden: yes
        }

        measure: date_inquery_check {
          type: number
          sql: {% if ext_paneldata_fce.date_date._is_selected  %}
                   1
                   {% elsif ext_paneldata_fce.date_week._is_selected %}
                   2
                  {% elsif ext_paneldata_fce.date_month._is_selected %}
                  3
                  {% elsif ext_paneldata_fce.date_quarter._is_selected %}
                  4
                  {% elsif ext_paneldata_fce.date_year._is_selected %}
                  5
                  {%else%}
                  6
                  {%endif%} ;;
          hidden: yes
        }

        measure: content_parameter_check {
          type: number
          sql: {% if avg_reach_content_granularity._parameter_value == 'Episode' %}
            1
            {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
            2
            {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
            3
            {%else%}
            4
            {%endif%} ;;
        hidden: yes
        }


  measure: content_inquery_check {
    type: number
    sql: {% if episodes.episodenumber_IFNULL._is_selected %}
            1
            {% elsif episodes.seasonnumber_IFNULL._is_selected or title_lookup.titleseason_fce._is_selected %}
            2
            {% elsif titlemaster.netflixid._is_selected or contentmaster.title._is_selected %}
            3
            {%else%}
            4
            {%endif%} ;;
    hidden: yes
  }



        dimension: date_parameter_value {
          type: date_raw
          sql: {% if avg_reach_date_granularity._parameter_value == 'Daily' %}
                  ${date_date}
                   {% elsif avg_reach_date_granularity._parameter_value == 'Weekly' %}
                  ${date_week}
                  {% elsif avg_reach_date_granularity._parameter_value == 'Monthly' %}
                  ${date_month}
                  {% elsif avg_reach_date_granularity._parameter_value == 'Quarterly' %}
                  ${date_quarter}
                  {% elsif avg_reach_date_granularity._parameter_value == 'Yearly' %}
                  ${date_year}
                  {%else%}
                  1
                  {%endif%} ;;
        hidden: yes
        }

        dimension: content_parameter_value {
          type: string
          sql: {% if avg_reach_content_granularity._parameter_value == 'Episode' %}
            ${title_lookup.titleseasonepisode_fce}
            {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
            ${title_lookup.titleseason_fce}
            {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
            ${title_lookup.titleonly_fce}
            {%else%}
            1
            {% endif %} ;;
        hidden: yes
        }





      }




######OLD CODE FOR AVG DENOMINATOR NEW

#         sql: {% if avg_reach_date_granularity._parameter_value == 'Daily' %}
#             {% if avg_reach_content_granularity._parameter_value == 'Episode' %}
#             count( distinct concat (${title_lookup.titleseasonepisode_fce}, ${ext_paneldata_fce.date_date}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
#             count( distinct concat(${title_lookup.titleseason_fce}, ${ext_paneldata_fce.date_date}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
#             count( distinct concat(${title_lookup.titleonly_fce}, ${ext_paneldata_fce.date_date}))
#             {%else%}
#             count (distinct ${ext_paneldata_fce.date_date})
#             {% endif %}
#       {% elsif avg_reach_date_granularity._parameter_value == 'Weekly' %}
#             {% if avg_reach_content_granularity._parameter_value == 'Episode' %}
#             count( distinct concat (${title_lookup.titleseasonepisode_fce}, ${ext_paneldata_fce.date_week}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
#             count( distinct concat(${title_lookup.titleseason_fce}, ${ext_paneldata_fce.date_week}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
#             count( distinct concat(${title_lookup.titleonly_fce}, ${ext_paneldata_fce.date_week}))
#             {%else%}
#             count (distinct ${ext_paneldata_fce.date_week})
#             {% endif %}
#       {% elsif avg_reach_date_granularity._parameter_value == 'Monthly' %}
#             {% if avg_reach_content_granularity._parameter_value == 'Episode' %}
#             count( distinct concat(${title_lookup.titleseasonepisode_fce}, ${ext_paneldata_fce.date_month}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
#             count( distinct concat(${title_lookup.titleseason_fce}, ${ext_paneldata_fce.date_month}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
#             count( distinct concat(${title_lookup.titleonly_fce}, ${ext_paneldata_fce.date_month}))
#             {%else%}
#             count (distinct ${ext_paneldata_fce.date_month})
#             {% endif %}
#       {% elsif avg_reach_date_granularity._parameter_value == 'Quarterly' %}
#             {% if avg_reach_content_granularity._parameter_value == 'Episode' %}
#             count( distinct concat(${title_lookup.titleseasonepisode_fce}, ${ext_paneldata_fce.date_quarter}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
#             count( distinct concat(${title_lookup.titleseason_fce}, ${ext_paneldata_fce.date_quarter}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
#             count( distinct concat(${title_lookup.titleonly_fce}, ${ext_paneldata_fce.date_quarter}))
#             {%else%}
#             count (distinct ${ext_paneldata_fce.date_quarter})
#             {% endif %}
#       {% elsif avg_reach_date_granularity._parameter_value == 'Yearly' %}
#             {% if avg_reach_content_granularity._parameter_value == 'Episode' %}
#             count( distinct concat(${title_lookup.titleseasonepisode_fce}, ${ext_paneldata_fce.date_year}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
#             count( distinct concat(${title_lookup.titleseason_fce}, ${ext_paneldata_fce.date_year}))
#             {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
#             count( distinct concat(${title_lookup.titleonly_fce}, ${ext_paneldata_fce.date_year}))
#             {%else%}
#             count (distinct ${ext_paneldata_fce.date_year})
#             {% endif %}
#       {% else %}
#       case when ${ext_paneldata_fce.noofitems_for_average_new}>0 then ${ext_paneldata_fce.noofitems_for_average_new} else 1 end
#       {% endif %}
#       ;;

include: "/*/*"

view: paneldata {


    extends: [paneldata_base]




#######################################################################################
##Parameters
#######################################################################################

  parameter: reachfrequency {
    type: unquoted
    default_value: "1"
    view_label: "Frequency"
    label: "Reach Frequency Filter"
    description: "This is the Least number of times a household has watched the criteria selected"
  }



  parameter: content_granularity {
    view_label: "Measures"
    group_label: "General granularity level for Measures: "
    group_item_label: "Content level"
    label: "Content Granularity"
    description: "Use for defining granularity at a content level for dynamic content name and for Reach calculations"
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

  parameter: date_granularity {

    view_label: "Measures"
    group_label: "General granularity level for Measures: "
    group_item_label: "Activity Timeframe level"
    label: "Period Granularity"
    description: "Use for defining granularity at a date level for reach calculation and dynamic axis configuration in vizuals"
    type: unquoted
    default_value: "1"

    allowed_value: {
      label: "Date"
      value: "Date"
    }
    allowed_value: {
      label: "Week"
      value: "Week"
    }
    allowed_value: {
      label: "Month"
      value: "Month"
    }
    allowed_value: {
      label: "Quarter"
      value: "Quarter"
    }
    allowed_value: {
      label: "Year"
      value: "Year"
    }

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

    allowed_value: {
      label: ""
      value: "1"
    }

  }



  filter: Title_selection {
    suggest_dimension: paneldata.content_name_dynamic
    suggestable: yes
    label: "Content Selection"
    description: "Use to filter content within selected granularity"
    ## This is for title comparison dashboard, filter that can give suggestions at the selected gran level
  }


#######################################################################################
##Measures
#######################################################################################

################   Reach

  measure: reach {
    view_label: "Measures"
    group_label: "Reach"
    label: "Reach (000s)"
    description: "Number of unique accounts (000s) that watched content at least x times, x defined by Reach Frequency Filter"
    #description: "This returns the latest weights of the households who have watched the criteria brought into the query at least x times"
    type: sum
    sql: {% if ndt_reach_dashboards.rowno._is_selected %} ${internationalweights.thousandsweight} {% else %} case when ${ndt_reach_dashboards.rowno} =  {%parameter reachfrequency %} then ${internationalweights.thousandsweight} else 0 end {% endif %}
      ;;
    ##DS 13/03/20 added condition on the rowno selection to be able to plot reach by frequency
    value_format: "#,##0"
  }


#   measure: reach_test {
#     view_label: "Measures"
#     group_label: "Reach"
#     label: "Reach (test)"
#     description: "This returns the latest weights of the households who have watched the criteria brought into the query at least x times"
#     type: sum
#     sql: {% if ndt_reach_dashboards.rowno._is_selected %} ${ndt_reach_dashboards.thousandsweight} {% else %} case when ${ndt_reach_dashboards.rowno} =  {%parameter reachfrequency %} then ${ndt_reach_dashboards.thousandsweight} else 0 end {% endif %}
#       ;;
#     ##DS 13/03/20 added condition on the rowno selection to be able to plot reach by frequency
#     value_format: "#,##0"
#   }

  measure: reach_percent {
    view_label: "Measures"
    group_label: "Reach"
    label: "Reach %"
    description: "Reach (000s) as a % of filtered population, available breakdowns: by country, quarter and year"
    type: number
    value_format: "0.0\%"
    ##sql: ${reach}/${uni_size.filtered_population} ;;
    sql: (${reach}/${paneldata.dynamic_pop_size})*100 ;;
  }

# ################   Average Reach
#
#   measure: avg_reach {
#     view_label: "Measures"
#     group_label: "Reach"
#     #label: "Average Reach (000s)"
#     #label_from_parameter: avg_reach_content_granularity
#     label: "Average {% if avg_reach_date_granularity._is_filtered and avg_reach_date_granularity._parameter_value <> '1' %}
#     {% parameter avg_reach_date_granularity %}
#     {%else%}
#     {%endif%}
#     Reach (000s)
#     {% if avg_reach_content_granularity._is_filtered and avg_reach_content_granularity._parameter_value <> '1' %}
#     per {% parameter avg_reach_content_granularity %}
#     {%else%}
#     {%endif%} OLD"
#     description: "Average is calculated based on content and/or activity timeframe criteria selected"
#     #description: "This returns the average Reach of the households who have watched the criteria brought into the query at least x times, average is calculated based on content and/or date granularity criteria"
#     type: average_distinct
#     #sql: case when ${avg_rowno} =  {% parameter ndt_reach_dashboards.reachfrequency %} and ${select_rowno}=1 then ${sumreach} else null end  ;;
#     sql: case when  ${ndt_avg_reach_dashboards.select_rowno}=1 then ${ndt_avg_reach_dashboards.sumreach} else null end  ;;
# #     html: {% if {{rendered_value}} == paneldata.reach._rendered_value %} {{value| round: 0}} This is equal to Reach, please check your average parameter is set to a more detailed level the the breakdown in query!
# #     {% else %}
# #     {{value| round: 0}}
# #     {% endif %};;
#     value_format: "#,##0"
#   }
#   ###TO BE COMMENTED OUT






################   Universe Size
#   measure: filtered_pop {
#     type: average
#     sql: ${uni_size_dashboards.filtered_population} ;;
#     view_label: "Measures"
#     #hidden: yes
#     ## If Unisize remains as a single view, move this calculation into paneldata base view
#   }


#   measure: pop_size {
#     type: average
#     sql: {% if paneldata.countrynameformaps._in_query %}
#                   {% if paneldata.date_date._is_selected or paneldata.date_granularity._parameter_value == 'Date'%
#                      or paneldata.date_week._is_selected or paneldata.date_granularity._parameter_value == 'Week'
#                      or paneldata.date_month._is_selected or paneldata.date_granularity._parameter_value == 'Month'
#                      or paneldata.date_quarter._is_selected or paneldata.date_granularity._parameter_value == 'Quarter'
#                     %} ${pop_size_dashboards.countryquarterpop}
#                   {% elsif paneldata.date_year._is_selected or paneldata.date_granularity._parameter_value == 'Year' %} ${pop_size_dashboards.countryyearpop}
#                   {% else %} ${pop_size_dashboards.countrypop} {% endif %}
#          {% else %}
#                    {% if paneldata.date_date._is_selected or paneldata.date_granularity._parameter_value == 'Date'%
#                      or paneldata.date_week._is_selected or paneldata.date_granularity._parameter_value == 'Week'
#                      or paneldata.date_month._is_selected or paneldata.date_granularity._parameter_value == 'Month'
#                      or paneldata.date_quarter._is_selected or paneldata.date_granularity._parameter_value == 'Quarter'
#                     %} ${pop_size_dashboards.allquarterpop}
#                   {% elsif paneldata.date_year._is_selected or paneldata.date_granularity._parameter_value == 'Year' %} ${pop_size_dashboards.allyearpop}
#                   {% else %} ${pop_size_dashboards.allpop} {% endif %}
#
#          {% endif %}
#     ;;
#     view_label: "Measures"
#     label: "Population 000s"
#     description: "Minimum granularity for population size is quarter - if you break viewing down by month, respective quarter's population size will be shown"
#     value_format: "#,##0"
#   }

  measure: dynamic_pop_size {
    type: average
    sql: ${pop_size_dashboards.dynamic}  ;;
    view_label: "Measures"
    label: "Population 000s"
    description: "Minimum granularity for population size is quarter filterable by demographic parameters, breakdown by demographic groups is not yet available"
    value_format: "#,##0"
  }



# ################   AVERAGE STREAMS DYNAMIC CALCULATION
#
#   dimension: noofitems_for_average {
#     view_label: "TEMP"
#     label: "Number of Items for Average"
#     type:  number
#     value_format_name: decimal_0
#     description: "Dynamically calculated number of episodes for each content level"
#     sql: case when ({% if avg_reach_content_granularity._parameter_value == 'Episode' %}
#          count (distinct ${title_lookup.titleseasonepisode})
#          {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
#          count (distinct ${title_lookup.titleseason})
#         {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
#         count (distinct ${title_lookup.titleonly})
#         {%else%} 1
#         {%endif%})
#         > 0 then
#         {% if avg_reach_content_granularity._parameter_value == 'Episode' %}
#          count (distinct ${title_lookup.titleseasonepisode})
#          {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
#          count (distinct ${title_lookup.titleseason})
#         {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
#         count (distinct ${title_lookup.titleonly})
#         {%else%} 1
#         {%endif%}
#         else 1 end
#
#         ;;
#     hidden: yes
# ##TO BE COMMENTED OUT
#
#   }
#
#
#   dimension: denominator_period {
#     label: "Content denominator"
#     view_label: "TEMP"
#     value_format_name: decimal_0
#     hidden: yes
#     type: number
#     sql: {% if avg_reach_date_granularity._parameter_value == 'Daily' %} count (distinct ${paneldata.date_date})
#       {% elsif avg_reach_date_granularity._parameter_value == 'Weekly' %} count (distinct ${paneldata.date_week})
#       {% elsif avg_reach_date_granularity._parameter_value == 'Monthly' %} count (distinct ${paneldata.date_month})
#       {% elsif avg_reach_date_granularity._parameter_value == 'Quarterly' %} count (distinct ${paneldata.date_quarter})
#       {% elsif avg_reach_date_granularity._parameter_value == 'Yearly' %} count (distinct ${paneldata.date_year})
#       {% else %} 1
#       {% endif %}
#       ;;
#       ##TO BE COMMENTED OUT
#
#     }
#
#
#
#     measure: avg_streams {
#       label: "Avg
#       {% if avg_reach_date_granularity._is_filtered and avg_reach_date_granularity._parameter_value <> '1' %}
#       {% parameter avg_reach_date_granularity %}
#       {% else %} {% endif %}
#       Streams (000s)
#       {% if avg_reach_content_granularity._is_filtered and avg_reach_content_granularity._parameter_value <> '1' %} per {% parameter avg_reach_content_granularity %} {% else %} {% endif %}
#       OLD"
#       description: "Average is calculated based on content and/or activity timeframe criteria selected"
#       view_label: "Measures"
#       group_label: "Streams"
#       value_format: "#,##0"
#       type: number
#       sql: ${paneldata.streams}/(${noofitems_for_average}*(${denominator_period})) ;;
#       ##TO BE COMMENTED OUT
#     }





#######################################################################################
##Dimensions
#######################################################################################




  dimension: content_name_dynamic {
    label: "Content name"
    type:  string
    view_label: "Content Selection"
    group_label: "Content"

    description: "Dynamic field, dependent on the content granularity selection"

    sql:
         {% if content_granularity._parameter_value == "Title" %}
         ${title_lookup.titleonly}
          {% elsif content_granularity._parameter_value == "Season" %}
         ${title_lookup.titleseason}
         {% elsif content_granularity._parameter_value == "Episode" %}
         ${title_lookup.titleseasonepisode}
         {% else %}
         ${title_lookup.titleonly}
         {% endif %}
           ;;

    link: {
      label: "Explore Title..."
      url: "https://digitali.eu.looker.com/dashboards/
{% if titlemaster.videotype._value == 'Series' %}203{% else %}204{% endif %}
?Title={{contentmaster.title._value}}&Country={{ _filters['paneldata.countrynameformaps'] }}"
    }

#     link: {
#       label: "{% if content_granularity._parameter_value ==  'Episode' and titlemaster.videotype._value == 'Series' %} Explore Episode... {% else %} {% endif %}"
#       url: "{{ paneldata.urlstring_exploreepisode._value }}"
#      }
    }

#     dimension: urlstring_exploreepisode {
#       hidden: yes
#       type: string
#       sql: 'https://digitali.eu.looker.com/dashboards/174?Title='||${contentmaster.title}||'&Country='||${paneldata.countrynameformaps}||
#       '&Season='||
#       {% if content_granularity._parameter_value ==  'Episode' %}
#       coalesce(${episodes.seasonnumber},'1'){% else %} '1' {% endif %}
#       ||'&Episode='||
#       {% if content_granularity._parameter_value ==  'Episode' %}
#       coalesce(${episodes.episodenumber},'1'){% else %} '1' {% endif %} ;;
#
#     }




    dimension: date_dynamic {
      label: "{% if date_granularity._is_filtered %} {% parameter date_granularity %} {% else %} Dynamic Date {% endif %}"
      view_label: "Activity Timeframe Selection"
      group_label: "Activity Timeframe"
      sql: {% if date_granularity._parameter_value == 'Date'  %}
              ${paneldata.date_date}
              {% elsif  date_granularity._parameter_value == 'Month' %}
              ${paneldata.date_month}
              {% elsif  date_granularity._parameter_value == 'Week' %}
              ${paneldata.date_week}
              {% elsif  date_granularity._parameter_value == 'Quarter' %}
              concat(year(${paneldata.date_raw}),' Q',date_part(quarter,${paneldata.date_raw}))
              {% elsif  date_granularity._parameter_value == 'Year' %}
              ${paneldata.date_year}
              {% else %}
              ${paneldata.date_date}
              {% endif %} ;;
      can_filter: no
    }




########Days since first viewed

  dimension: datefirstviewed  {
    label: "Date First Viewed"
    view_label: "Content Selection"
    group_label: "Content"
    description: "Dynamic depending on if episode, season or title are included in the query"
    type: date
    sql: {%if episodes.episodenumber_IFNULL._in_query or paneldata.content_granularity._parameter_value == 'Episode'%}
         ${releasedate.mintitleseasonepisodedate}
          {%elsif episodes.seasonnumber_IFNULL._in_query or paneldata.content_granularity._parameter_value == 'Season'%}
         ${releasedate.mintitleseasondate}
        {%else%}
         ${releasedate.mintitledate}
        {%endif%}
        ;;

    }





  filter: dayssincefirstviewed {
    type: number
    view_label: "Activity Timeframe Selection"
    label: "Days Since First Viewed Filter"
    description: "Use to limit days since first view to figures above zero (exclude likely VPN viewing)"
    sql: {% condition dayssincefirstviewed %} ${days_timesincedatefirstviewed} {% endcondition %};;
  }





  dimension_group: timesincedatefirstviewed {
    type: duration
    intervals: [day, week]
#   sql_start: ${releasedate.datefirstviewed};;
    sql_start: ${paneldata.datefirstviewed} ;;
    sql_end: ${paneldata.date_raw} ;;
    view_label: "Activity Timeframe Selection"
    group_label: "Days/ Weeks Since First Viewed"
    label: "Since First Viewed"
    description: "Use the [Less than or Equal to] operator and enter the number of days/ weeks to see an activity time window (from when the content was first viewed plus x days/ weeks)"

  }





















  ########################################################
  ##ADDITIONAL STUFF

  measure: selected_episode {
    type:  sum
    sql:  case when ${episodes.episodenumber_IFNULL} = {% parameter episode_selection %} then ${internationalweights.thousandsweight} else null end  ;;
    value_format: "#,##0"
    view_label: "TEMP"
    group_label: "Episode Selection"
    description: "Episode selection for Episode Explorer"
    #hidden: yes
  }
  measure: other_episodes {
    type:  sum
    sql:  case when ${episodes.episodenumber_IFNULL} = {% parameter episode_selection %} then null else ${internationalweights.thousandsweight} end  ;;
    value_format: "#,##0"
    view_label: "TEMP"
    group_label: "Episode Selection"
    description: "Episode selection for Episode Explorer"
    #hidden: yes
  }
  parameter: episode_selection {
    type: number
    view_label: "TEMP"
    description: "Episode selection for Episode Explorer"
    #hidden: yes
  }




  #############################################
  ##MANUAL TEXT

  parameter: custom_text {
    type: string
    view_label: "TEMP"
    description: "This is for building text boxes that have some better formatting than default ones. select both filter and dimention, put your text in the filter."
  }
  dimension: custom_text_dim {
    type: string
    view_label: "TEMP"
    group_label: "Creating text tile"
    description: "This is for building text boxes that have some better formatting than default ones. select both filter and dimention, put your text in the filter."
    sql: {% parameter paneldata.custom_text %} ;;
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
    sql: ${paneldata.streams}/${average_denominator_new} ;;
    html: {% if avg_reach_content_granularity._is_filtered and avg_reach_date_granularity._is_filtered %}
                    {% if (paneldata.content_inquery_check._value > paneldata.content_parameter_check._value) AND (paneldata.date_inquery_check._value > paneldata.date_parameter_check._value) %}
                    {{rendered_value}}
                    {% else %} {{rendered_value}} Please make sure your average granularity is more detailed than the breakdown in your data table
                    {% endif %}
              {% elsif avg_reach_content_granularity._is_filtered or avg_reach_date_granularity._is_filtered %}
                    {% if (paneldata.date_inquery_check._value > paneldata.date_parameter_check._value) or (paneldata.content_inquery_check._value > paneldata.content_parameter_check._value) %}
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
    sql: ( sum({% if ndt_reach_dashboards.rowno._is_selected %} ${ndt_reach_dashboards.thousandsweight} {% else %} case when ${ndt_reach_dashboards.avg_rowno} =  {%parameter reachfrequency %} then ${ndt_reach_dashboards.thousandsweight} else 0 end {% endif %}))
      /${average_denominator_new} ;;
#         html: {% if {{rendered_value}} == ext_paneldata_fce.reach._rendered_value %} {{value| round: 0}} This is equal to Reach, please check your average parameter is set to a more detailed level the the breakdown in query!
#               {% else %}
#               {{value| round: 0}}
#               {% endif %};;
    html: {% if avg_reach_content_granularity._is_filtered and avg_reach_date_granularity._is_filtered %}
                {% if (paneldata.content_inquery_check._value > paneldata.content_parameter_check._value) AND (paneldata.date_inquery_check._value > paneldata.date_parameter_check._value) %}
                {{rendered_value}}
                {% else %} {{rendered_value}} Please make sure your average granularity is more detailed than the breakdown in your data table
                {% endif %}
          {% elsif avg_reach_content_granularity._is_filtered or avg_reach_date_granularity._is_filtered %}
                {% if (paneldata.date_inquery_check._value > paneldata.date_parameter_check._value) or (paneldata.content_inquery_check._value > paneldata.content_parameter_check._value) %}
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
        sql: IFNULL(count (distinct ${title_lookup.titleseasonepisode}),1)
          ;;
        can_filter: no
      }


#       filter: noofepisodes_global_filter_title {
#         type: number
#         view_label: "Content Selection"
#         label: "Global number of episodes in a title"
#         description: "This allows to filter by number of episodes, however this takes into account all available episodes within piece of content up to date (non date or country specific!). "
#         suggest_dimension: title_lookup.counttitlelevel
#         sql: {% condition noofepisodes_global_filter_title_season %} ${title_lookup.counttitlelevel} {% endcondition %};;
#       }
#
#
#
#       filter: noofepisodes_global_filter_title_season {
#         type: number
#         view_label: "Content Selection"
#         label: "Global number of episodes in a season"
#         description: "This allows to filter by number of episodes, however this takes into account all available episodes within piece of content up to date (non date or country specific!). "
#         suggest_dimension: title_lookup.countseasonlevel
#         sql: {% condition noofepisodes_global_filter_title_season %} ${title_lookup.countseasonlevel} {% endcondition %} ;;
#       }



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
        sql: {% if paneldata.date_date._is_selected or paneldata.date_granularity._parameter_value == 'Date' %}
                   1
                   {% elsif paneldata.date_week._is_selected or paneldata.date_granularity._parameter_value == 'Week' %}
                   2
                  {% elsif paneldata.date_month._is_selected or paneldata.date_granularity._parameter_value == 'Month' %}
                  3
                  {% elsif paneldata.date_quarter._is_selected or paneldata.date_granularity._parameter_value == 'Quarter' %}
                  4
                  {% elsif paneldata.date_year._is_selected or paneldata.date_granularity._parameter_value == 'Year' %}
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
        sql: {% if episodes.episodenumber_IFNULL._is_selected or paneldata.content_granularity._parameter_value == 'Episode' %}
            1
            {% elsif episodes.seasonnumber_IFNULL._is_selected or paneldata.content_granularity._parameter_value == 'Season' %}
            2
            {% elsif titlemaster.netflixid._is_selected or contentmaster.title._is_selected or paneldata.content_granularity._parameter_value == 'Title' %}
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
            ${title_lookup.titleseasonepisode}
            {% elsif avg_reach_content_granularity._parameter_value == 'Season' %}
            ${title_lookup.titleseason}
            {% elsif avg_reach_content_granularity._parameter_value == 'Title' %}
            ${title_lookup.titleonly}
            {%else%}
            1
            {% endif %} ;;
        hidden: yes
      }








  }

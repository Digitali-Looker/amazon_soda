include: "/*/*/*"
include: "/*/*"

view: ndt_dynamic_targeting {
  derived_table: {
    explore_source: ext_paneldata_fce {
      column: rid { field: householddemo.rid }
      column: country {field: ext_paneldata_fce.country}
      #------------------------------------------------------------------------------------------------------
      #DS 28/05/20 columns below added for segmentation
      column: streams {field:ext_paneldata_fce.streams}
      column: average_weight { field: ext_paneldata_fce.average_weight }

      derived_column: total_thou {
        sql:  sum (streams) over (partition by {% if ext_paneldata_fce.countrynameformaps_is_selected %} country {% else %} 1 {% endif %});;
        }
      ##This condition here is so that when 2 or more countries are filtered, we can look at viewers of smth across countries as a single subset (total will also be across countries)
      ##This should tie in nicely with pop size calculation that only partitions by country if it is selected in the query
      ## if only one country is filtered then the whole list will be limited to 1 country, so partitioning is mot needed

#       derived_column: percent_viewing_ind_row {
#         sql: (streams/total_thou)*100 ;;
#       }
#

      derived_column: running_streams_intermediate {
        sql: sum (streams) over (
                  partition by {% if ext_paneldata_fce.countrynameformaps_is_selected %} country {% else %} 1 {% endif %}
                  order by {% if ext_paneldata_fce.countrynameformaps_is_selected %} country {% else %} 1 {% endif %}, streams, average_weight
                  );;
      }


      derived_column: percent_viewing_running {
        sql: (running_streams_intermediate/total_thou)*100 ;;
      }


      derived_column: total_rows {
        sql: count(1) OVER (partition by {% if ext_paneldata_fce.countrynameformaps_is_selected %} country {% else %} 1 {% endif %}) ;;
      }
      ##This condition here is so that when 2 or more countries are filtered, we can look at viewers of smth across countries as a single subset (total will also be across countries)
      ##This should tie in nicely with pop size calculation that only partitions by country if it is selected in the query
      ## if only one country is filtered then the whole list will be limited to 1 country, so partitioning is mot needed

      derived_column: percent_sample_running {
        sql: ROW_NUMBER () OVER (
        partition by {% if ext_paneldata_fce.countrynameformaps_is_selected %} country {% else %} 1 {% endif %}
        ORDER BY streams, average_weight
        )/total_rows*100 ;;
      }
      #Running % is from top to bottom viewing, so top 30% will be heavy


      derived_column: sample_threshold_flag {
        sql: case when {% condition ndt_dynamic_targeting.custom_threshold_sample %} percent_sample_running {% endcondition %} then 1 else 0 end
        ;;

      }

      derived_column: viewing_threshold_flag {
        sql: case when {% condition ndt_dynamic_targeting.custom_threshold_viewing %} percent_viewing_running {% endcondition %} then 1 else 0 end
          ;;

      }



      #-------------------------------------------------------------------------------------------------------

      bind_filters: {
        to_field: ext_paneldata_fce.countrynameformaps
        from_field: ext_paneldata_fce.countrynameformaps
      }

      bind_filters: {
        to_field: contentmaster.title
        from_field: ndt_dynamic_targeting.titlefilter
      }

      bind_filters: {
        to_field: episodes.seasonnumber_IFNULL
        from_field: ndt_dynamic_targeting.seasonnumber_IFNULLFilter
      }

#         bind_filters: {
#           to_field: episodes.episodenumber_IFNULL
#           from_field: ndt_dynamic_targeting_dashboards.episodenumber_IFNULLFilter
#         }
# We can add episode selection, But I don't want to add the title&season&episode combo now, because it would become too confusing
#for now let's limit selection to (title and/or season) OR title&season combo

#       bind_filters: {
#         to_field: netflixoriginals.IsNetflixOriginalFullName
#         from_field: ndt_dynamic_targeting.IsNetflixOriginalFullNameFilter
#       }

#       bind_filters: {
#         to_field: genresflattened.genre
#         from_field: ndt_dynamic_targeting.genreFilter
#       }

      bind_filters: {
        to_field: ext_paneldata_fce.dayssincefirstviewed
        from_field: ndt_dynamic_targeting.dayssincefirstviewedfilter
      }

      bind_filters: {
        to_field: title_lookup.titleseason_fce
        from_field: ndt_dynamic_targeting.titleseasonfilter
      }


      bind_filters: {
        to_field: ext_paneldata_fce.date_date
        from_field: ndt_dynamic_targeting.datefilter
      }


    }

  }
  dimension: rid {
    type: number
    hidden: yes
  }

  dimension: country {
    type: string
    hidden: yes
  }

  dimension: streams {
    type: number
    value_format: "0.###"
    hidden: yes
  }

  dimension: average_weight {
    type: number
    value_format: "0.###"
    hidden: yes
  }

#     filter: countrynameformapsfilter {
#       type: string
#       view_label: "Dynamic Targeting Filters"
#       label: "Country"
#       suggest_dimension: paneldata.countrynameformaps
#     }

  filter: titlefilter {
    type: string
    view_label: "Dynamic Targeting Filters"
    label: "Title"
    suggest_dimension: contentmaster.title
  }

  filter: seasonnumber_IFNULLFilter {
    type: string
    view_label: "Dynamic Targeting Filters"
    label: "Season"
    suggest_dimension: episodes.seasonnumber_IFNULL
  }

#   filter: IsNetflixOriginalFullNameFilter {
#     type: string
#     view_label: "Dynamic Targeting Filters"
#     label: "Is Netflix Original?"
#     suggest_dimension: netflixoriginals.IsNetflixOriginalFullName
#     hidden: yes ##SDR following MR request 19/08/2020
#   }

#   filter: genreFilter {
#     type: string
#     view_label: "Dynamic Targeting Filters"
#     label: "Primary Genre"
#     suggest_dimension: genresflattened.genre
#   }

  filter: dayssincefirstviewedfilter {
    type: number
    view_label: "Dynamic Targeting Filters"
    label: "Days Since First Viewed"
    description: "To cover days from first view to day N use 'less than' configuration in the filtering section"
  }

  filter: titleseasonfilter {
    type: string
    view_label: "Dynamic Targeting Filters"
    label: "Title - Season"
    suggest_explore: ext_paneldata_fce
    suggest_dimension: title_lookup.titleseason_fce
  }

  filter: datefilter {
    type: date
    view_label: "Dynamic Targeting Filters"
    label: "Activity Date"
  }

  dimension: percent_viewing {
    type: number
    view_label: "Dynamic Targeting Filters"
    group_label: "Heavy/Medium/Light"
    label: "Running percent viewing for test"
    #hidden: yes
    sql: ${TABLE}.percent_viewing_running ;;
    hidden: yes
  }

  dimension: percent_sample {
    type: number
    view_label: "Dynamic Targeting Filters"
    group_label: "Heavy/Medium/Light"
    label: "Running percent sample for test"
    #hidden: yes
    sql: ${TABLE}.percent_sample_running ;;
    hidden: yes
  }

  dimension: HML_viewing {
    type: string
    view_label: "Dynamic Targeting Filters"
    group_label: "Heavy/Medium/Light"
    label: "Heavy/Medium/Light by % of viewing"
    description: "This status dimension splits viewers into 3 groups, each contributing a third of overall viewing. Viewers are ordered by their streams and then split into thirds by cumulative streams reaching a threshold."
    sql: case when ${percent_viewing}<=33.33 then 'Light' when ${percent_viewing}<=66.66 then 'Medium' when ${percent_viewing}<=101 then 'Heavy' else 'Fail' end ;;
  hidden: yes
  }

  dimension: HML_sample {
    type: string
    view_label: "Dynamic Targeting Filters"
    group_label: "Heavy/Medium/Light"
    label: "Heavy/Medium/Light by % of sample"
    description: "This status dimension splits viewers into 3 equally sized groups. Viewers are ordered by their streams and then split into thirds by cumulative number of respondents reaching a threshold."
    sql: case when ${percent_sample}<=33.33 then 'Light' when ${percent_sample}<=66.66 then 'Medium' when ${percent_sample}<=100 then 'Heavy' else 'Fail' end ;;
  }


  dimension: sample_threshold_flag {
    type: number
    sql: ${TABLE}.sample_threshold_flag ;;
    hidden: yes
  }

  dimension: viewing_threshold_flag {
    type: number
    sql: ${TABLE}.viewing_threshold_flag ;;
    hidden: yes
  }

  filter: custom_threshold_viewing{
    type: number
    view_label: "Dynamic Targeting Filters"
    group_label: "Custom Thresholds"
    label: "Custom threshold for selection by % of viewing"
    description: "Select the range of percentage you would like to see, for instance to see viewers that delivered top 30% select between 0 and 31 or less than or equal to 30"
  hidden: yes
  }


  filter: custom_threshold_sample {
    type: number
    view_label: "Dynamic Targeting Filters"
    #group_label: "Custom Thresholds"
    label: "Custom threshold for selection by % of sample"
    description: "Select the range of percentage you would like to see, for instance to see lightest 30% of viewers select between 0 and 30 (inclusive) or less than or equal to 30"
  }


}

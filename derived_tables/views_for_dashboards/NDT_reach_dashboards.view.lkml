view: ndt_reach_dashboards {
############################################
##DS
##03/03/2020
##This is a replica or the original NDT_reach that is used in the client explore, that then had the granularity parameters added to it to allow for building dashboard looks that are dynamic.
#############################################

############################
##Notes: Average Reach doesn't work as expected cause its summarising all the weights and takes those with rowno for averaging, should be the other way around - summing only those with rowno1 and then averaging it.
##Try separating average reach calculation into a separate NDT
############################




derived_table: {

  explore_source: dashboardexplore {

    column: netflixid             { field: titlemaster.netflixid }
    column: title                 { field: contentmaster.title   }
    column: videotype             {field:  titlemaster.videotype}
    column: seasonnumber_IFNULL   { field: episodes.seasonnumber_IFNULL }    ##should this be the IFNULL version??
    column: episodenumber_IFNULL  { field: episodes.episodenumber_IFNULL }
    column: date_raw              { field: paneldata.date_raw}
    column: rid                   { field: paneldata.respondantid }
    column: diid                  {field:  paneldata.diid}
    column: country               {field:  paneldata.country}
    column: rid_country           { field: paneldata.rid_country}
    column: thousandsweight       { field: internationalweights.thousandsweight}
#     column: genre                 {field: genresflattened.genre}
#     column: IsNetflixOriginalFullName {field:netflixoriginals.IsNetflixOriginalFullName}
#     column: firstcountry          {field: imdbinfo.firstcountry} #DS 29/06/20
#     column: language              {field: imdbinfo.language}  #DS 29/06/20
#     column: rating                {field: imdbinfo.rating}  #DS 29/06/20
#     column: runtime               {field: imdbinfo.runtime}  #DS 29/06/20
    column: released              {field: contentmaster.released}  #DS 29/06/20
#     column: seasonlevelclassification  {field: vw_netflixoriginalsexclusives.seasonlevelclassification}  #SDR 11/08/2020
#     column: latestclassification  {field: vw_netflixoriginalsexclusives.latestclassification}  #SDR 19/08/2020
    derived_column: PK {
      sql: ROW_NUMBER () OVER (ORDER BY NULL) ;;
    }
    derived_column: rowno {
      sql: ROW_NUMBER () OVER (PARTITION BY rid_country,

                                     {%if titlemaster.netflixid._is_selected or contentmaster.title._is_selected
                                      or paneldata.content_granularity._parameter_value == 'Title'
                                      or paneldata.content_granularity._parameter_value == 'Season'
                                      or paneldata.content_granularity._parameter_value == 'Episode'
                                      %} netflixid
                                     {%else%} 1
                                     {% endif %},

                                     {%if titlemaster.videotype._is_selected %} videotype
                                     {%else%} 1
                                     {% endif %},


                                     {%if episodes.seasonnumber_IFNULL._is_selected
                                      or paneldata.content_granularity._parameter_value == 'Season'
                                      or paneldata.content_granularity._parameter_value == 'Episode'
                                      %} seasonnumber_IFNULL
                                     {%else%} 1
                                     {% endif %},

                                     {%if episodes.episodenumber_IFNULL._is_selected or paneldata.content_granularity._parameter_value == 'Episode'%} episodenumber_IFNULL
                                     {%else%} 1
                                     {% endif %},

                                     {%if paneldata.date_date._is_selected or paneldata.date_granularity._parameter_value == 'Date'%} date_raw
                                     {%else%} 1
                                     {% endif %},

                                     {%if paneldata.date_week._is_selected or paneldata.date_granularity._parameter_value == 'Week'%} date_trunc(week,date_raw)
                                     {%else%} 1
                                     {% endif %},

                                     {%if paneldata.date_month._is_selected or paneldata.date_granularity._parameter_value == 'Month'%} date_trunc(month,date_raw)
                                     {%else%} 1
                                     {% endif %},

                                     {%if paneldata.date_quarter._is_selected or paneldata.date_granularity._parameter_value == 'Quarter'%} date_trunc(quarter,date_raw)
                                     {%else%} 1
                                     {% endif %},

                                     {%if paneldata.date_year._is_selected or paneldata.date_granularity._parameter_value == 'Year'%} date_part(year,date_raw)
                                     {%else%} 1
                                     {% endif %},

                                     {%if contentmaster.released._is_selected %} released
                                     {%else%} 1
                                     {% endif %},

                 {%if paneldata.countrynameformaps._is_selected %} country
                 {%else%} 1
                 {% endif %}

                                    ORDER BY rid_country, date_raw desc) ;;
    }

    derived_column: avg_rowno {
      sql: ROW_NUMBER () OVER (PARTITION BY rid_country,

                                                 {%if paneldata.avg_reach_content_granularity._is_filtered
                                                  or titlemaster.netflixid._is_selected or contentmaster.title._is_selected
                                                  or paneldata.content_granularity._is_filtered
                                                  %} netflixid
                                                 {%else%} 1
                                                 {% endif %},

                                     {%if titlemaster.videotype._is_selected %} videotype
                                     {%else%} 1
                                     {% endif %},


                                                 {%if paneldata.avg_reach_content_granularity._parameter_value == 'Season'
                                                  or paneldata.avg_reach_content_granularity._parameter_value == 'Episode'
                                                  or episodes.seasonnumber_IFNULL._is_selected
                                                  or paneldata.content_granularity._parameter_value == 'Season'
                                                  %} seasonnumber_IFNULL
                                                 {%else%} 1
                                                 {% endif %},

                                                 {%if paneldata.avg_reach_content_granularity._parameter_value == 'Episode'
                                                  or episodes.episodenumber_IFNULL._is_selected or paneldata.content_granularity._parameter_value == 'Episode'
                                                  %} episodenumber_IFNULL
                                                 {%else%} 1
                                                 {% endif %},

                                                 {%if paneldata.avg_reach_date_granularity._parameter_value == 'Daily'
                                                   or paneldata.date_date._is_selected or paneldata.date_granularity._parameter_value == 'Date'
                                                  %} date_raw
                                                 {%else%} 1
                                                 {% endif %},

                                                 {%if paneldata.avg_reach_date_granularity._parameter_value == 'Weekly'
                                                   or paneldata.date_week._is_selected or paneldata.date_granularity._parameter_value == 'Week'
                                                  %} date_trunc(week,date_raw)
                                                 {%else%} 1
                                                 {% endif %},

                                                 {%if paneldata.avg_reach_date_granularity._parameter_value == 'Monthly'
                                                  or paneldata.date_month._is_selected or paneldata.date_granularity._parameter_value == 'Month'
                                                  %} date_trunc(month,date_raw)
                                                 {%else%} 1
                                                 {% endif %},

                                                 {%if paneldata.avg_reach_date_granularity._parameter_value == 'Quarterly'
                                                  or paneldata.date_quarter._is_selected or paneldata.date_granularity._parameter_value == 'Quarter'
                                                  %} date_trunc(quarter,date_raw)
                                                 {%else%} 1
                                                 {% endif %},

                                                 {%if paneldata.avg_reach_date_granularity._parameter_value == 'Yearly'
                                                  or paneldata.date_year._is_selected or paneldata.date_granularity._parameter_value == 'Year'
                                                  %} date_part(year,date_raw)
                                                 {%else%} 1
                                                 {% endif %},

                                                 {%if contentmaster.released._is_selected %} released
                                                 {%else%} 1
                                                 {% endif %},

                 {%if paneldata.countrynameformaps._is_selected %} country
                 {%else%} 1
                 {% endif %}

                                                ORDER BY rid_country, date_raw desc) ;;
    }



    bind_all_filters: yes





  }
}




#######################################################################################
##Dimensions
#######################################################################################


dimension: PK {
  primary_key: yes
  hidden: yes
}

dimension: rowno {
  type: number
  label: "Frequency N+"
  description: "Use for plotting Reach by Frequncy (N+) distribution"
  view_label: "Frequency"
  #hidden: yes
  can_filter: no
}

dimension: avg_rowno {
  type: number
  hidden: yes
}

#   dimension: sumreach {
#     label: "Reach for average (000s)"
#     type: number
#     hidden: yes
#   }

dimension: thousandsweight {
  label: "thousandsweight"
  type: number
  hidden: yes
}





#######################################################################################

dimension: netflixid {
#     label: "Content Selection TEMPORARY Netflix ID"
value_format: "0"
type: number
hidden:  yes
}

dimension: title {
#     label: "Content Selection Title"
hidden: yes
}


dimension: videotype {
#     label: "Content Selection Title"
hidden: yes
}

dimension: genre {
  hidden: yes
}

dimension: seasonnumber_IFNULL {
#     label: "Content Selection Season Number"
hidden: yes
}

dimension: episodenumber_IFNULL {
#     label: "Content Selection Episode Number"
hidden: yes
}

dimension: date_raw {
#     label: "Activity Timeframe Selection Activity Date"
type: date
hidden: yes
}

dimension: rid {
#     label: "Demographic Information Household ID"
value_format: "0"
type: number
hidden: yes
}

dimension: diid {
#     label: "Content Selection Episode Number"
hidden: yes
}

dimension: country {
  hidden: yes
}

dimension: IsNetflixOriginalFullName {
  hidden: yes
}

dimension: firstcountry {
  hidden: yes
}

dimension: language {
  hidden: yes
}

dimension: rating {
  hidden: yes
}

dimension: runtime {
  hidden: yes
}

dimension: released {
  hidden: yes
}

dimension: rid_country {
  hidden: yes
}

}




## All the possible filters to replace bind all filters and allow for explore extend! Important - if adding a dimention or filter that can be filtered and can potentially affect reach add it here
#
#       bind_filters: {
#         from_field: titlemaster.netflixid
#         to_field: titlemaster.netflixid
#       }
#         bind_filters: {
#           from_field: contentmaster.title
#           to_field: contentmaster.title
#         }
#         bind_filters: {
#           from_field: titlemaster.videotype
#           to_field: titlemaster.videotype
#         }
#         bind_filters: {
#           from_field: episodes.seasonnumber_IFNULL
#           to_field: episodes.seasonnumber_IFNULL
#         }
#         bind_filters: {
#           from_field: paneldata.date_raw
#           to_field: paneldata.date_raw
#         }
#         bind_filters: {
#           from_field: paneldata.respondantid
#           to_field: paneldata.respondantid
#         }
#         bind_filters: {
#           from_field: paneldata.diid
#           to_field: paneldata.diid
#         }
#         bind_filters: {
#           from_field: paneldata.country
#           to_field: paneldata.country
#         }
#         bind_filters: {
#           from_field: episodes.episodenumber_IFNULL
#           to_field: episodes.episodenumber_IFNULL
#         }
#         bind_filters: {
#           from_field: internationalweights.thousandsweight
#           to_field: internationalweights.thousandsweight
#         }
#         bind_filters: {
#           from_field: householddemo.haskids
#           to_field: householddemo.haskids
#         }
#           bind_filters: {
#             from_field: releasedate_dashboards.dayssincefirstviewed
#             to_field: releasedate_dashboards.dayssincefirstviewed
#           }
#           bind_filters: {
#             from_field: paneldata.Title_selection
#             to_field: paneldata.Title_selection
#           }
#           bind_filters: {
#             from_field: releasedate_dashboards.datefirstviewed
#             to_field: releasedate_dashboards.datefirstviewed
#           }
#           bind_filters: {
#             from_field: netflixoriginals.IsNetflixOriginalFullName
#             to_field: netflixoriginals.IsNetflixOriginalFullName
#           }
#           bind_filters: {
#             from_field: contentmaster.rating
#             to_field: contentmaster.rating
#           }
#           bind_filters: {
#             from_field: genresflattened.genre
#             to_field: genresflattened.genre
#           }
#           bind_filters: {
#             from_field: titlegenres.genre
#             to_field: titlegenres.genre
#           }
#           bind_filters: {
#             from_field: householddemo.accountholderagegroup
#             to_field: householddemo.accountholderagegroup
#           }
#           bind_filters: {
#             from_field: householddemo.accountholdergender
#             to_field: householddemo.accountholdergender
#           }
#           bind_filters: {
#             from_field: householddemo.rid
#             to_field: householddemo.rid
#           }
#           bind_filters: {
#             from_field: paneldata.netflixprofileid
#             to_field: paneldata.netflixprofileid
#           }
#           bind_filters: {
#             from_field: householddemo.has16_to34
#             to_field: householddemo.has16_to34
#           }
#           bind_filters: {
#             from_field: householddemo.has16_to44
#             to_field: householddemo.has16_to44
#           }
#           bind_filters: {
#             from_field: householddemo.kidsgroup
#             to_field: householddemo.kidsgroup
#           }
#           bind_filters: {
#             from_field: householddemo.sec
#             to_field: householddemo.sec
#           }
#           bind_filters: {
#             from_field: householddemo.secgroup
#             to_field: householddemo.secgroup
#           }
#           bind_filters: {
#             from_field: householddemo.householdsize
#             to_field: householddemo.householdsize
#           }
#           bind_filters: {
#             from_field: householddemo.hasprime
#             to_field: householddemo.hasprime
#           }
#           bind_filters: {
#             from_field: householddemo.housholdplatform
#             to_field: householddemo.housholdplatform
#           }
#           bind_filters: {
#             from_field: ndt_genretitlestreams_dashboards.rowno
#             to_field: ndt_genretitlestreams_dashboards.rowno
#           }




#                                      {%if imdbinfo.firstcountry._is_selected %} firstcountry
#                                      {%else%} 1
#                                      {% endif %},
#
#                                      {%if imdbinfo.language._is_selected %} language
#                                      {%else%} 1
#                                      {% endif %},
#
#                                      {%if imdbinfo.rating._is_selected %} rating
#                                      {%else%} 1
#                                      {% endif %},
#
#                                      {%if imdbinfo.runtime._is_selected %} runtime
#                                      {%else%} 1
#                                      {% endif %},
#
#                                      {%if netflixoriginals.IsNetflixOriginalFullName._is_selected %} IsNetflixOriginalFullName
#                                      {%else%} 1
#                                      {% endif %},

#                                      {%if genresflattened.genre._is_selected %} genre
#                                      {%else%} 1
#                                      {% endif %},
#                                     --SDR 11/08/2020 and 19/08/2020---------
#                  {%if vw_netflixoriginalsexclusives.latestclassification._is_selected %} latestclassification
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if vw_netflixoriginalsexclusives.seasonlevelclassification._is_selected %} seasonlevelclassification
#                  {%else%} 1
#                  {% endif %},
#  ---------------------------------------
#
#
#                                                  {%if imdbinfo.firstcountry._is_selected %} firstcountry
#                                                  {%else%} 1
#                                                  {% endif %},
#
#                                                  {%if imdbinfo.language._is_selected %} language
#                                                  {%else%} 1
#                                                  {% endif %},
#
#                                                  {%if imdbinfo.rating._is_selected %} rating
#                                                  {%else%} 1
#                                                  {% endif %},
#
#                                                  {%if imdbinfo.runtime._is_selected %} runtime
#                                                  {%else%} 1
#                                                  {% endif %},
#
#                                                  {%if netflixoriginals.IsNetflixOriginalFullName._is_selected %} IsNetflixOriginalFullName
#                                                  {%else%} 1
#                                                  {% endif %},

#                                      {%if genresflattened.genre._is_selected %} genre
#                                      {%else%} 1
#                                      {% endif %},
#                                     --SDR 11/08/2020 and 19/08/2020---------
#                  {%if vw_netflixoriginalsexclusives.latestclassification._is_selected %} latestclassification
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if vw_netflixoriginalsexclusives.seasonlevelclassification._is_selected %} seasonlevelclassification
#                  {%else%} 1
#                  {% endif %},
#  ---------------------------------------

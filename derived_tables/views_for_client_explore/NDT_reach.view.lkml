############################################
##SDR
##20/02/2020
#############################################

############################
##Changes - DS
##28/02/2020
##Added Diid & country into the mix to ensure the most granular level in this NDT and therefore less chance of a mess up in the join
##Replaced EpisodeNumber and SeasonNumber to IFNULL versions, this allowed for correct calculation of Reach in combination with Ndays since first view filter.
##Added VideoType to the partitioning so that when split by movies vs series same person could be contributing towards both
############################


#######################
## DS 03/03/20
##When average Reach is completed for dashboard NDTs, mirror the methodology here for client explore
###########################

view: NDT_reach {

  derived_table: {

    explore_source: ext_paneldata_fce {

      column: netflixid             { field: titlemaster.netflixid }
      column: title                 { field: contentmaster.title   }
      column: videotype             { field: titlemaster.videotype}
      column: seasonnumber_IFNULL   { field: episodes.seasonnumber_IFNULL }    ##should this be the IFNULL version??
      column: episodenumber_IFNULL  { field: episodes.episodenumber_IFNULL }
      column: date_raw              { field: ext_paneldata_fce.date_raw}
      column: rid                   { field: ext_paneldata_fce.respondantid }
      column: profileid             { field: ext_paneldata_fce.netflixprofileid}  ##SDR 18/06/2020 added in to test that it hopefully doesnt fan things out but want to be able to order by this
      column: diid                  { field: ext_paneldata_fce.diid}
      column: country               { field: ext_paneldata_fce.country}
      column: rid_country           { field: ext_paneldata_fce.rid_country}
      column: thousandsweight       { field: internationalweights.thousandsweight}
      column: genre                 { field: genresflattened.genre}
#       column: IsNetflixOriginalFullName {field:netflixoriginals.IsNetflixOriginalFullName}
#       column: firstcountry          {field: imdbinfo.firstcountry} #DS 29/06/20
#       column: language              {field: imdbinfo.language}  #DS 29/06/20
#       column: rating                {field: imdbinfo.rating}  #DS 29/06/20
#       column: runtime               {field: imdbinfo.runtime}  #DS 29/06/20
      column: released              {field: contentmaster.released}  #DS 29/06/20
#       column: seasonlevelclassification  {field: vw_netflixoriginalsexclusives.seasonlevelclassification}  #SDR 11/08/2020
#       column: latestclassification  {field: vw_netflixoriginalsexclusives.latestclassification}  #SDR 19/08/2020
      derived_column: PK {
                sql: ROW_NUMBER () OVER (ORDER BY NULL) ;;
      }
      derived_column: rowno {
                 sql: ROW_NUMBER () OVER (PARTITION BY rid_country,

                 {%if titlemaster.netflixid._is_selected or contentmaster.title._is_selected or title_lookup.titleseason_fce._is_selected %} netflixid
                 {%else%} 1
                 {% endif %},
                 {%if titlemaster.videotype._is_selected %} videotype
                 {%else%} 1
                 {% endif %},
                 {%if episodes.seasonnumber_IFNULL._is_selected or title_lookup.titleseason_fce._is_selected %} seasonnumber_IFNULL
                 {%else%} 1
                 {% endif %},
                 {%if episodes.episodenumber_IFNULL._is_selected %} episodenumber_IFNULL
                 {%else%} 1
                 {% endif %},
                 {%if ext_paneldata_fce.date_date._is_selected %} date_raw
                 {%else%} 1
                 {% endif %},
                 {%if ext_paneldata_fce.date_week._is_selected %} date_trunc(week,date_raw)
                 {%else%} 1
                 {% endif %},
                 {%if ext_paneldata_fce.date_month._is_selected %} date_trunc(month,date_raw)
                 {%else%} 1
                 {% endif %},
                 {%if ext_paneldata_fce.date_quarter._is_selected %} date_trunc(quarter,date_raw)
                 {%else%} 1
                 {% endif %},
                 {%if ext_paneldata_fce.date_year._is_selected %} date_part(year,date_raw)
                 {%else%} 1
                 {% endif %},
                 {%if contentmaster.released._is_selected %} released
                 {%else%} 1
                 {% endif %},
        ----DS 09/10/20
                 {%if genresflattened.genre._is_selected %} genre
                 {%else%} 1
                 {% endif %},
 ---------------------------------------
                 {%if ext_paneldata_fce.countrynameformaps._is_selected %} country
                 {%else%} 1
                 {% endif %}
                ORDER BY rid_country,  date_raw desc, profileid) ;;    ##SDR 18/06/2020 added in to  be able to order by ProfileID too-- note that profileID needs to go at the end so as not to disturb the latest date selected!!
                        }
#                   {%if ext_paneldata_fce.netflixprofileid._is_selected %} netflixprofileid
#                  {%else%} 1
#                  {% endif %},

#              ORDER BY country, rid, date_raw desc) ;;


      derived_column: avg_rowno {
        sql: ROW_NUMBER () OVER (PARTITION BY rid_country,

                 {%if ext_paneldata_fce.avg_reach_content_granularity._parameter_value == 'Title'
                  or ext_paneldata_fce.avg_reach_content_granularity._parameter_value == 'Season'
                  or ext_paneldata_fce.avg_reach_content_granularity._parameter_value == 'Episode'
                  or titlemaster.netflixid._is_selected or contentmaster.title._is_selected or title_lookup.titleseason_fce._is_selected
                  %} netflixid
                 {%else%} 1
                 {% endif %},

                 {%if titlemaster.videotype._is_selected %} videotype
                 {%else%} 1
                 {% endif %},

                 {%if ext_paneldata_fce.avg_reach_content_granularity._parameter_value == 'Season'
                  or ext_paneldata_fce.avg_reach_content_granularity._parameter_value == 'Episode'
                  or episodes.seasonnumber_IFNULL._is_selected or title_lookup.titleseason_fce._is_selected
                  %} seasonnumber_IFNULL
                 {%else%} 1
                 {% endif %},

                 {%if ext_paneldata_fce.avg_reach_content_granularity._parameter_value == 'Episode'
                  or episodes.episodenumber_IFNULL._is_selected
                  %} episodenumber_IFNULL
                 {%else%} 1
                 {% endif %},

                 {%if ext_paneldata_fce.avg_reach_date_granularity._parameter_value == 'Daily'
                  or ext_paneldata_fce.date_date._is_selected
                  %} date_raw
                 {%else%} 1
                 {% endif %},

                 {%if ext_paneldata_fce.avg_reach_date_granularity._parameter_value == 'Weekly'
                 or ext_paneldata_fce.date_week._is_selected %} date_trunc(week,date_raw)
                 {%else%} 1
                 {% endif %},

                 {%if ext_paneldata_fce.avg_reach_date_granularity._parameter_value == 'Monthly'
                  or ext_paneldata_fce.date_month._is_selected %} date_trunc(month,date_raw)
                 {%else%} 1
                 {% endif %},

                 {%if ext_paneldata_fce.avg_reach_date_granularity._parameter_value == 'Quarterly'
                  or ext_paneldata_fce.date_quarter._is_selected %} date_trunc(quarter,date_raw)
                 {%else%} 1
                 {% endif %},

                 {%if ext_paneldata_fce.avg_reach_date_granularity._parameter_value == 'Yearly'
                  or ext_paneldata_fce.date_year._is_selected %} date_part(year,date_raw)
                 {%else%} 1
                 {% endif %},

                 {%if contentmaster.released._is_selected %} released
                 {%else%} 1
                 {% endif %},

              ----DS 09/10/20
                 {%if genresflattened.genre._is_selected %} genre
                 {%else%} 1
                 {% endif %},


                 {%if ext_paneldata_fce.countrynameformaps._is_selected %} country
                 {%else%} 1
                 {% endif %}

                ORDER BY rid_country,  date_raw desc, profileid) ;;    ##SDR 18/06/2020 added in to  be able to order by ProfileID too-- note that profileID needs to go at the end so as not to disturb the latest date selected!!
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
    label: "Frequency N+"
    description: "Use for plotting Reach by Frequncy (N+) distribution"
    view_label: "Frequency"
    type: number
    can_filter: no
    #hidden: yes
  }

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

  dimension: avg_rowno {
    hidden: yes
  }


  dimension: IsNetflixOriginalFullName {
    hidden: yes
  }

##SDR 18/06/2020 - just to pull this through but is hidden :)
  dimension: profileid {
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




#                  {%if imdbinfo.firstcountry._is_selected %} firstcountry
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if imdbinfo.language._is_selected %} language
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if imdbinfo.rating._is_selected %} rating
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if imdbinfo.runtime._is_selected %} runtime
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if netflixoriginals.IsNetflixOriginalFullName._is_selected %} IsNetflixOriginalFullName
#                  {%else%} 1
#                  {% endif %},

#                 --SDR 11/08/2020 and 19/08/2020---------
#                  {%if vw_netflixoriginalsexclusives.latestclassification._is_selected %} latestclassification
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if vw_netflixoriginalsexclusives.seasonlevelclassification._is_selected %} seasonlevelclassification
#                  {%else%} 1
#                  {% endif %},
#
#
#
#                  {%if imdbinfo.firstcountry._is_selected %} firstcountry
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if imdbinfo.language._is_selected %} language
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if imdbinfo.rating._is_selected %} rating
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if imdbinfo.runtime._is_selected %} runtime
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if netflixoriginals.IsNetflixOriginalFullName._is_selected %} IsNetflixOriginalFullName
#                  {%else%} 1
#                  {% endif %},
#                 {%if genresflattened.genre._is_selected %} genre
#                 {%else%} 1
#                 {% endif %},
#                 --SDR 11/08/2020 and 19/08/2020---------
#                  {%if vw_netflixoriginalsexclusives.latestclassification._is_selected %} latestclassification
#                  {%else%} 1
#                  {% endif %},
#
#                  {%if vw_netflixoriginalsexclusives.seasonlevelclassification._is_selected %} seasonlevelclassification
#                  {%else%} 1
#                  {% endif %},
#  ---------------------------------------

###################
## DS 04/03/20
## This NDT is to be built off the base of reach_dashbards
#################

#################################
## Technically sumreach here could be used as a normal reach figure and controlled by same granularity parameters, no particular need to separate them (apart from if we want to hgave both reach and ave reach in the same table)
## However, a) I want to be able to have them in the same table like have a season level reach figure and also have an average reach per episode for each season as well
## b) This is a trial for average reach calculations that would be added to the client facing explore - the one that doesn't have granularity parameters for normal reach calculation
##
##################################

##################
## If the average reach is at a less granular level than overall reach it looks a bit weird, cause it passes a value for 1st occurence but then nulls for the rest, think of solutions for that
##################



view: ndt_avg_reach_dashboards {

  derived_table: {

    explore_source: dashboardexplore {



      column: netflixid             {field: ndt_reach_dashboards.netflixid}
      column: title                 {field: ndt_reach_dashboards.title}
      column: videotype             {field: ndt_reach_dashboards.videotype}
      column: seasonnumber_IFNULL   {field: ndt_reach_dashboards.seasonnumber_IFNULL}
      column: episodenumber_IFNULL  {field: ndt_reach_dashboards.episodenumber_IFNULL}
      column: date_raw              {field: ndt_reach_dashboards.date_raw}
      column: rid                   {field: ndt_reach_dashboards.rid}
      column: diid                  {field: ndt_reach_dashboards.diid}
      column: country               {field: ndt_reach_dashboards.country}
      column: rid_country           {field: ndt_reach_dashboards.rid_country}
      column: thousandsweight       {field: ndt_reach_dashboards.thousandsweight}
      column: genre                 {field: ndt_reach_dashboards.genre}
      column: IsNetflixOriginalFullName {field:ndt_reach_dashboards.IsNetflixOriginalFullName}
      column: firstcountry          {field: ndt_reach_dashboards.firstcountry} #DS 29/06/20
      column: language              {field: ndt_reach_dashboards.language}  #DS 29/06/20
      column: rating                {field: ndt_reach_dashboards.rating}  #DS 29/06/20
      column: runtime               {field: ndt_reach_dashboards.runtime}  #DS 29/06/20
      column: released              {field: ndt_reach_dashboards.released}  #DS 29/06/20
      column: avg_rowno             {field: ndt_reach_dashboards.avg_rowno}
      column: PK                    {field: ndt_reach_dashboards.PK}
      derived_column: PK2 {
        sql: ROW_NUMBER () OVER (ORDER BY NULL) ;;}
      derived_column: weight {
        sql: case when avg_rowno = {% parameter paneldata.reachfrequency %} then thousandsweight else 0 end ;;    }
      derived_column: sumreach {
        sql: sum(weight)
          OVER (PARTITION BY

                                         {%if paneldata.avg_reach_content_granularity._is_filtered
                                          or titlemaster.netflixid._is_selected or contentmaster.title._is_selected
                                          or paneldata.content_granularity._is_filtered
                                          %} netflixid
                                         {%else%} 1
                                         {% endif %},

                             {%if titlemaster.videotype._is_selected %} videotype
                             {%else%} 1
                             {% endif %},

                             {%if genresflattened.genre._is_selected %} genre
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

                                         {%if netflixoriginals.IsNetflixOriginalFullName._is_selected %} IsNetflixOriginalFullName
                                         {%else%} 1
                                         {% endif %},

                                         {%if imdbinfo.firstcountry._is_selected %} firstcountry
                                         {%else%} 1
                                         {% endif %},

                                         {%if imdbinfo.language._is_selected %} language
                                         {%else%} 1
                                         {% endif %},

                                         {%if imdbinfo.rating._is_selected %} rating
                                         {%else%} 1
                                         {% endif %},

                                         {%if imdbinfo.runtime._is_selected %} runtime
                                         {%else%} 1
                                         {% endif %},

                                         {%if contentmaster.released._is_selected %} released
                                         {%else%} 1
                                         {% endif %},

                                         {%if paneldata.countrynameformaps._is_selected %} country
                                         {%else%} 1
                                         {% endif %}



                                        ) ;;
      }
      ##this select_rowno is for getting distinct sum for average calculation, so the number of occurences doesn't screw the overall average
      derived_column: select_rowno {
        sql: ROW_NUMBER ()
          OVER (PARTITION BY

                                         {%if paneldata.avg_reach_content_granularity._is_filtered
                                          or titlemaster.netflixid._is_selected or contentmaster.title._is_selected
                                          or paneldata.content_granularity._is_filtered

                                          %} netflixid
                                         {%else%} 1
                                         {% endif %},

                             {%if titlemaster.videotype._is_selected %} videotype
                             {%else%} 1
                             {% endif %},

                             {%if genresflattened.genre._is_selected %} genre
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

                                         {%if netflixoriginals.IsNetflixOriginalFullName._is_selected %} IsNetflixOriginalFullName
                                         {%else%} 1
                                         {% endif %},

                                         {%if imdbinfo.firstcountry._is_selected %} firstcountry
                                         {%else%} 1
                                         {% endif %},

                                         {%if imdbinfo.language._is_selected %} language
                                         {%else%} 1
                                         {% endif %},

                                         {%if imdbinfo.rating._is_selected %} rating
                                         {%else%} 1
                                         {% endif %},

                                         {%if imdbinfo.runtime._is_selected %} runtime
                                         {%else%} 1
                                         {% endif %},

                                         {%if contentmaster.released._is_selected %} released
                                         {%else%} 1
                                         {% endif %},

                                         {%if paneldata.countrynameformaps._is_selected %} country
                                         {%else%} 1
                                         {% endif %}

              order by rid_country, date_raw desc

                                        ) ;;
      }

      #bind_all_filters: yes




    }

  }





#######################################################################################
##Dimensions
#######################################################################################


  dimension: PK2 {
    primary_key: yes
    hidden: yes
  }

  dimension: PK {
    type: number
    hidden: yes
  }

  dimension: avg_rowno {
    type: number
    hidden: yes
  }

  dimension: select_rowno {
    type: number
    hidden: yes
  }

  dimension: sumreach {
    label: "Reach for average (000s)"
    #type: average
    sql: ${TABLE}.sumreach;;
    hidden: yes
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


}

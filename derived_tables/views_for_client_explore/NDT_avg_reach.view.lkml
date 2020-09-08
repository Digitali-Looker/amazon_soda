view: ndt_avg_reach {
  ###################
## DS 06/03/20
## This NDT is to be built off the base of ndt_reach
#################

#################################
## This is a replica of Average Reach from Dashboard explore, except it doesn't use Reach granularity parameters and only relies on avg reach params and what's in query
##
##
##
##################################

##################
## select_rowno is meant to tackle a problem of sum of weights appearing multiple times (cause its summed over), which skews the average slightly.
##Also by adding _is_selected conditions to the partitioning, we allow for correct representation even if a user selects less granular avg reach level than their data table (for instance reach at an episode level, but average reach at a season level)
##################





    derived_table: {

      explore_source: ext_paneldata_fce {



        column: netflixid             {field: NDT_reach.netflixid}
        column: title                 {field: NDT_reach.title}
        column: videotype             {field: NDT_reach.videotype}
        column: seasonnumber_IFNULL   {field: NDT_reach.seasonnumber_IFNULL}
        column: episodenumber_IFNULL  {field: NDT_reach.episodenumber_IFNULL}
        column: date_raw              {field: NDT_reach.date_raw}
        column: rid                   {field: NDT_reach.rid}
        column: diid                  {field: NDT_reach.diid}
        column: country               {field: NDT_reach.country}
        column: rid_country           {field: NDT_reach.rid_country}
        column: thousandsweight       {field: NDT_reach.thousandsweight}
        column: genre                 {field: NDT_reach.genre}
        column: IsNetflixOriginalFullName {field: NDT_reach.IsNetflixOriginalFullName}
        column: firstcountry          {field: NDT_reach.firstcountry} #DS 29/06/20
        column: language              {field: NDT_reach.language}  #DS 29/06/20
        column: rating                {field: NDT_reach.rating}  #DS 29/06/20
        column: runtime               {field: NDT_reach.runtime}  #DS 29/06/20
        column: released              {field: NDT_reach.released}  #DS 29/06/20
        column: avg_rowno             {field: NDT_reach.avg_rowno}
        column: PK                    {field: NDT_reach.PK}
        derived_column: PK2 {
          sql: ROW_NUMBER () OVER (ORDER BY NULL) ;;}
        derived_column: weight {
          sql: case when avg_rowno = {% parameter ext_paneldata_fce.reachfrequency %} then thousandsweight else 0 end ;;    }
        derived_column: sumreach {
          sql: sum(weight)
                      OVER (PARTITION BY

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

                                        {%if genresflattened.genre._is_selected %} genre
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
                                                      or ext_paneldata_fce.date_date._is_selected %} date_raw
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

                                                   {%if ext_paneldata_fce.countrynameformaps._is_selected %} country
                                                   {%else%} 1
                                                   {% endif %}



                                                    ) ;;
        }
        ##this select_rowno is for getting distinct sum for average calculation, so the number of occurences doesn't screw the overall average
        derived_column: select_rowno {
          sql: ROW_NUMBER ()
                      OVER (PARTITION BY

                                                     {%if ext_paneldata_fce.avg_reach_content_granularity._is_filtered
                                                      or titlemaster.netflixid._is_selected or contentmaster.title._is_selected or title_lookup.titleseason_fce_is_selected


                                                      %} netflixid
                                                     {%else%} 1
                                                     {% endif %},

                                        {%if titlemaster.videotype._is_selected %} videotype
                                        {%else%} 1
                                        {% endif %},

                                        {%if genresflattened.genre._is_selected %} genre
                                        {%else%} 1
                                        {% endif %},


                                                     {%if ext_paneldata_fce.avg_reach_content_granularity._parameter_value == 'Season'
                                                      or ext_paneldata_fce.avg_reach_content_granularity._parameter_value == 'Episode'
                                                      or episodes.seasonnumber_IFNULL._is_selected
                                                      or title_lookup.titleseason_fce_is_selected


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
                                                      or ext_paneldata_fce.date_week._is_selected
                                                      %} date_trunc(week,date_raw)
                                                     {%else%} 1
                                                     {% endif %},

                                                     {%if ext_paneldata_fce.avg_reach_date_granularity._parameter_value == 'Monthly'
                                                      or ext_paneldata_fce.date_month._is_selected
                                                      %} date_trunc(month,date_raw)
                                                     {%else%} 1
                                                     {% endif %},

                                                     {%if ext_paneldata_fce.avg_reach_date_granularity._parameter_value == 'Quarterly'
                                                      or ext_paneldata_fce.date_quarter._is_selected
                                                      %} date_trunc(quarter,date_raw)
                                                     {%else%} 1
                                                     {% endif %},

                                                     {%if ext_paneldata_fce.avg_reach_date_granularity._parameter_value == 'Yearly'
                                                      or ext_paneldata_fce.date_year._is_selected
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

                                                     {%if ext_paneldata_fce.countrynameformaps._is_selected %} country
                                                     {%else%} 1
                                                     {% endif %}

                          order by rid_country, date_raw desc

                                                    ) ;;
        }

       # bind_all_filters: yes







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

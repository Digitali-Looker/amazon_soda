#############################
##13/02/2020
##TF
#############################

connection: "amazon_soda"

include: "/*/*"
include: "/*/*/*"

datagroup: netflix_int_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: netflix_int_default_datagroup


# explore: nav_bar {}   --SDR 18/03/2020

explore: navigation_bar {
#   hidden: yes   ##SDR 15/09/2020 unhidden temporarily while building the dashboard :D
} ##SDR 18/03/2020




explore: ext_paneldata_fce {


  ##fields: [ALL_FIELDS*,-ext_paneldata_fce.custom_text,-ext_paneldata_fce.custom_text_dim, -ext_paneldata_fce.selected_episode, -ext_paneldata_fce.other_episodes, -ext_paneldata_fce.episode_selection]

  fields: [ALL_FIELDS*, -title_lookup.titleonly, -title_lookup.titleseason, -title_lookup.titleseasonepisode]

  label: "Amazon Client Explore"


#   always_filter: {
#     filters: {
#       field: ext_paneldata_fce.countrynameformaps
#     }
#   }

  #############################################################################################################################
  ## DS 20/03/20
  ## Adding base explore joins


  sql_always_where: ${titlemaster.netflixid} is not null
  and ( ${ext_paneldata_fce.titleid} is not null)
  and ${country} in ( {{ _user_attributes['netflix_v2_country_access'] }} )
  and ${date_raw} >= '{{ _user_attributes['netflix_v2_start'] }}'
  and ${date_raw} <= '{{ _user_attributes['netflix_v2_end'] }}'
  and ${contentmaster.title} is not null
      --and ${householddemo.demoid} IS NOT NULL
      ;;    ##SDR 02032020 -to get around
      ##TF 13032020 - commented our demoid is not null due to Internationalweighting


      #DS added always join
    always_join: [titlemaster,householddemo,internationalweights]


    join: titlemaster {
      sql_on: ${ext_paneldata_fce.titleid} = ${titlemaster.titleid} ;;
      relationship: many_to_one
    }

    join: contentmaster {
      sql_on: ${contentmaster.netflixid} = ${titlemaster.netflixid} ;;
      relationship: many_to_one
    }

    join: episodes {
      sql_on: ${episodes.episodeid} = ${titlemaster.episodeid};;
      relationship: many_to_one
    }

##-----------------------------------------------------------------

    join: householddemo {
      sql_on: ${ext_paneldata_fce.respondantid} = ${householddemo.rid}
        and ${ext_paneldata_fce.country} = ${householddemo.country} ;;
      relationship: many_to_one
    }



    join: internationalweights {
      sql_on: ${ext_paneldata_fce.respondantid} = ${internationalweights.rid}
            and year(${ext_paneldata_fce.date_raw}) = ${internationalweights.panelyear}
               and QUARTER(${ext_paneldata_fce.date_raw}) = ${internationalweights.panelquarter}
               and ${ext_paneldata_fce.country} = ${internationalweights.country}
            ;;
      relationship: many_to_one
    }
    ## TF05 Added the join for InternationalWeights


  join: pop_size {
    sql_on: ${pop_size.country}=${ext_paneldata_fce.country} and ${pop_size.panelyear}=year(${ext_paneldata_fce.date_raw}) and ${pop_size.panelquarter}=QUARTER(${ext_paneldata_fce.date_raw})
      ;;
    relationship: many_to_one
  }


#     join:  genresflattened {
#       sql_on: ${genresflattened.netflixid} = ${titlemaster.netflixid} ;;
#       relationship: many_to_one
#     }

#     join: netflixoriginals {
#       sql_on: ${netflixoriginals.netflixid} = ${titlemaster.netflixid} ;;
#       relationship: many_to_one
#     }

# ##SDR 15/06/2020
#     join: imdbinfo {
#       sql_on: ${imdbinfo.netflixid} = ${titlemaster.netflixid} ;;
#       relationship: many_to_one
#     }

  ###############################################################################################################################

  join: title_lookup {
    sql_on: ${ext_paneldata_fce.titleid} = ${title_lookup.title_id} ;;
    relationship: many_to_one
    type: inner
  }



  join: NDT_reach {
    sql_on: ${NDT_reach.diid}=${ext_paneldata_fce.diid}
    and ${NDT_reach.country}=${ext_paneldata_fce.country}
    and ${NDT_reach.rid}=${ext_paneldata_fce.respondantid};;
    relationship: many_to_one
  }

#   join: ndt_avg_reach {
#     sql_on: ${NDT_reach.diid}=${ndt_avg_reach.diid}
#         and ${NDT_reach.country}=${ndt_avg_reach.country}
#         and ${NDT_reach.rid}=${ndt_avg_reach.rid}
#         and ${NDT_reach.PK}=${ndt_avg_reach.PK}
#         ;;
#        ## and ${ndt_avg_reach_dashboards.avg_rowno}=1;;
#       relationship: many_to_one
#     }
#     #commented out as no longer needed with new average reach measure DS 19/08/20

# DS 28/02/20 Replaced old joins to Diid,Country and RID - combination at the most granular level (DiIds duplacate across countries at the moment), it's still doing symmetric aggregate though, dunno why, but seems to calculate correctly.


#   join: numberofepisodes {
#     sql_on: ${titlemaster.netflixid} = ${numberofepisodes.netflixid}
#             and ifnull(${episodes.episodenumber},1) = ifnull(${numberofepisodes.episodenumber},1)
#             and ifnull(${episodes.seasonnumber},1) =  ifnull(${numberofepisodes.seasonnumber},1) ;;
#     relationship: many_to_one
#   }
# #commented out as no longer needed with new average reach measure DS 19/08/20

  join: releasedate {
    sql_on: ${titlemaster.netflixid} = ${releasedate.netflixid}
            and ${ext_paneldata_fce.country}=${releasedate.country}
            and ifnull(${episodes.episodenumber},1) = ifnull(${releasedate.episodenumber},1)
            and ifnull(${episodes.seasonnumber},1) = ifnull(${releasedate.seasonnumber},1) ;;
    relationship: many_to_one
  }

  join: ndt_dynamic_targeting {
    sql_on: ${householddemo.rid}=${ndt_dynamic_targeting.rid}
      and ${ext_paneldata_fce.country}=${ndt_dynamic_targeting.country}
      and ${ndt_dynamic_targeting.sample_threshold_flag}=1
      and ${ndt_dynamic_targeting.viewing_threshold_flag}=1;;
    relationship: many_to_one
    type: inner
  }

# join: vw_netflixoriginalsexclusives {
#   sql_on: ${vw_netflixoriginalsexclusives.titleid} = ${titlemaster.titleid} ;;
#   relationship: one_to_one
# }




}





####################################################################################################################################################
####################################################################################################################################################
####################################################################################################################################################
explore: dashboardexplore {

#   hidden: yes   --SDR 15/09/2020 - temp unhiding in dashboard creation

  view_name:  paneldata
  #extends: [base_paneldata]
  label: "DEV - Dashboard Building Explore"

  fields: [ALL_FIELDS*, -title_lookup.titleseason_fce, -title_lookup.titleonly_fce, -title_lookup.titleseasonepisode_fce]

#   always_filter: {
#     filters: {
#       field: paneldata.countrynameformaps
#     }
#   }


  #############################################################################################################################
  ## DS 20/03/20
  ## Adding base explore joins

  sql_always_where: ${titlemaster.netflixid} is not null and ( ${paneldata.titleid} is not null)
                    and ${country} in ( {{ _user_attributes['netflix_v2_country_access'] }} )
                    and ${date_raw} >= '{{ _user_attributes['netflix_v2_start'] }}'
                    and ${date_raw} <= '{{ _user_attributes['netflix_v2_end'] }}'
                    and ${contentmaster.title} is not null
  ;;
  #sql_always_where: ${titlemaster.netflixid} is not null and ${titlemaster.videotype} is not null;;

      ##TF 13032020 - commented our demoid is not null due to Internationalweighting


      #DS added always join
    always_join: [titlemaster,householddemo,internationalweights]


    join: titlemaster {
      sql_on: ${paneldata.titleid} = ${titlemaster.titleid} ;;
      relationship: many_to_one
    }

    join: contentmaster {
      sql_on: ${contentmaster.netflixid} = ${titlemaster.netflixid} ;;
      relationship: many_to_one
    }

    join: episodes {
      sql_on: ${episodes.episodeid} = ${titlemaster.episodeid};;
      relationship: many_to_one
    }

##-----------------------------------------------------------------

    join: householddemo {
      sql_on: ${paneldata.respondantid} = ${householddemo.rid}
        and ${paneldata.country} = ${householddemo.country} ;;
      relationship: many_to_one
    }



    join: internationalweights {
      sql_on: ${paneldata.respondantid} = ${internationalweights.rid}
            and year(${paneldata.date_raw}) = ${internationalweights.panelyear}
               and QUARTER(${paneldata.date_raw}) = ${internationalweights.panelquarter}
               and ${paneldata.country} = ${internationalweights.country}
            ;;
      relationship: many_to_one
    }
    ## TF05 Added the join for InternationalWeights


    join: pop_size_dashboards {
      sql_on: ${pop_size_dashboards.country}=${paneldata.country} and ${pop_size_dashboards.panelyear}=year(${paneldata.date_raw}) and ${pop_size_dashboards.panelquarter}=QUARTER(${paneldata.date_raw})
      ;;
      relationship: many_to_one
    }
    ## Adding other breakdowns didn't quite work yet
#       and {% if householddemo.sec._is_selected %} ${pop_size.sec}=${householddemo.sec} {% else %} 1=1 {% endif %}
#       and {% if householddemo.kidsgroup._is_selected %} ${pop_size.kidsgroup}=${householddemo.kidsgroup} {% else %} 1=1 {% endif %}
#       and {% if householddemo.secgroup._is_selected %} ${pop_size.secgroup}=${householddemo.secgroup} {% else %} 1=1 {% endif %}
#       and {% if householddemo.housholdplatform._is_selected %} ${pop_size.housholdplatform}=${householddemo.housholdplatform} {% else %} 1=1 {% endif %}


#     join:  genresflattened {
#       sql_on: ${genresflattened.netflixid} = ${titlemaster.netflixid} ;;
#       relationship: many_to_one
#     }

#     join: netflixoriginals {
#       sql_on: ${netflixoriginals.netflixid} = ${titlemaster.netflixid} ;;
#       relationship: many_to_one
#     }

# ##SDR 15/06/2020
#   join: imdbinfo {
#     sql_on: ${imdbinfo.netflixid} = ${titlemaster.netflixid} ;;
#     relationship: many_to_one
#   }

    ###############################################################################################################################





  join: ndt_reach_dashboards {
    sql_on: ${ndt_reach_dashboards.diid}=${paneldata.diid}
          and ${ndt_reach_dashboards.country}=${paneldata.country}
          and ${ndt_reach_dashboards.rid}=${paneldata.respondantid};;
    relationship: many_to_one
  }

  join: title_lookup {
  sql_on: ${paneldata.titleid} = ${title_lookup.title_id} ;;
  relationship: many_to_one
  type: inner
}



#   join: ndt_avg_reach_dashboards {
#     sql_on: ${ndt_reach_dashboards.diid}=${ndt_avg_reach_dashboards.diid}
#         and ${ndt_reach_dashboards.country}=${ndt_avg_reach_dashboards.country}
#         and ${ndt_reach_dashboards.rid}=${ndt_avg_reach_dashboards.rid}
#         and ${ndt_reach_dashboards.PK}=${ndt_avg_reach_dashboards.PK}
#         ;;
#        ## and ${ndt_avg_reach_dashboards.avg_rowno}=1;;
#     relationship: many_to_one
#   }
#   #Commented out as this is no loger needed with new average calculations DS 19/08/20


#   join: numberofepisodes_dashboards {
#     sql_on: ${titlemaster.netflixid} = ${numberofepisodes_dashboards.netflixid}
#             and ifnull(${episodes.episodenumber},1) = ifnull(${numberofepisodes_dashboards.episodenumber},1)
#             and ifnull(${episodes.seasonnumber},1) =  ifnull(${numberofepisodes_dashboards.seasonnumber},1) ;;
#     relationship: many_to_one
#   }
#   #Commented out as this is no loger needed with new average calculations DS 19/08/20



  join: releasedate {
    sql_on: ${titlemaster.netflixid} = ${releasedate.netflixid}
            and ${paneldata.country}=${releasedate.country}
            and ifnull(${episodes.episodenumber},1) = ifnull(${releasedate.episodenumber},1)
            and ifnull(${episodes.seasonnumber},1) = ifnull(${releasedate.seasonnumber},1) ;;
    relationship: many_to_one
  }

#   join: ndt_genretitlestreams_dashboards {
#     sql_on:
#             ${ndt_genretitlestreams_dashboards.netflixid} = ${genresflattened.netflixid}
#         and ${ndt_genretitlestreams_dashboards.genre}    = ${genresflattened.genre};;
#     relationship: many_to_one
#   }
  ##DS 18/03/20 Added a replica of genretitlestreams table based off primary genre, rather than non-unique genre

#   join: titlegenres {
#     sql_on: ${contentmaster.netflixid} = ${titlegenres.netflixid} ;;
#     relationship: one_to_many
# ##This is joined in to make genre filter work, any genre dashboards and looks should be made from didevexplore
# ##alternatively we can join the genretitlestream NDT here as well and kill dashboard explore altogether, but will have to rebuild the dashboard then
#   }

join: ndt_dynamic_targeting_dashboards {
  sql_on: ${householddemo.rid}=${ndt_dynamic_targeting_dashboards.rid}
  and ${paneldata.country}=${ndt_dynamic_targeting_dashboards.country}
  and ${ndt_dynamic_targeting_dashboards.sample_threshold_flag}=1
  and ${ndt_dynamic_targeting_dashboards.viewing_threshold_flag}=1;;
  relationship: many_to_one
  type: inner
}

##SDR 11/08/2020

#   join: vw_netflixoriginalsexclusives {
#     sql_on: ${vw_netflixoriginalsexclusives.titleid} = ${titlemaster.titleid} ;;
#     relationship: one_to_one
#   }



}

#####################################################
##TESTS - TF written added by SDR 11/08/2020
#####################################################

# test: uk_2019_streams {
#   explore_source: ext_paneldata_fce{
#     column: total_reach { field: ext_paneldata_fce.reach}
#     filters: [ext_paneldata_fce.date_year: "2019"]
#     filters: [ext_paneldata_fce.countrynameformaps: "United Kingdom"]
#   }
#   assert: uk_2019_reach_expected_value {
#     expression: round(${ext_paneldata_fce.reach},0) = 13409 ;;
#   }
# }
#
# test: uk_2019_strangerthings_reach {
#   explore_source: ext_paneldata_fce{
#     column: total_reach { field: ext_paneldata_fce.reach}
#     filters: [ext_paneldata_fce.date_year: "2019"]
#     filters: [ext_paneldata_fce.countrynameformaps: "United Kingdom"]
#     filters: [contentmaster.title: "Stranger Things"]
#   }
#   assert: uk_2019_strangerthings_reach_expected_value {
#     expression: round(${ext_paneldata_fce.reach},0) = 8029 ;;
#   }
# }
#
# test: uk_2019_strangerthings_streams {
#   explore_source: ext_paneldata_fce{
#     column: total_streams { field: ext_paneldata_fce.streams}
#     filters: [ext_paneldata_fce.date_year: "2019"]
#     filters: [ext_paneldata_fce.countrynameformaps: "United Kingdom"]
#     filters: [contentmaster.title: "Stranger Things"]
#   }
#   assert: uk_2019_streams_expected_value {
#     expression: round(${ext_paneldata_fce.streams},0) = 102556 ;;
#   }
# }


####################################################################################################################################################
####################################################################################################################################################
####################################################################################################################################################
#ADDITIONAL EXPLORES THAT ARE USED FOR INTERMEDIATE STEPS

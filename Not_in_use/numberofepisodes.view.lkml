####################
##SDR (taking from Neflix_Main)
##19/02/2020
####################



view: numberofepisodes {
  derived_table: {
    sql: select distinct e.Netflixid
      --
          ,e.seasonnumber
          ,e.episodenumber
          ,case when (count(e.episodenumber) over (partition by e.Netflixid))=0
                then 1
                else (count(e.episodenumber) over (partition by e.Netflixid)) end as TitleLevel
          ,case when (count(e.episodenumber) over (partition by e.Netflixid, e.SeasonNumber))=0
              then 1
              else  (count(e.episodenumber) over (partition by e.Netflixid, e.SeasonNumber)) end as SeasonLevel
          ,'1' as EpisodeLevel
      --
      FROM core.Episodes e
      --
      /*temp way of excluding extra autogen ids that were not watched and shouldn't affect total no of episodes */
      inner join
      core.TitleMaster tm
      on tm.NetflixID=e.Netflixid and tm.EpisodeID=e.EpisodeID
      --
      inner join core.PANELDATAINTERNATIONAL pdq
      on tm.TitleId = pdq.TitleId
      --
    where
      {% condition ext_paneldata_fce.date_raw  %} pdq.date  {% endcondition  %}
      and
      {% condition ext_paneldata_fce.countrynameformaps %} CASE WHEN pdq.country = 'UK' THEN 'United Kingdom' ELSE  pdq.country END {% endcondition %}
      --
      group by
        e.Netflixid,e.SeasonNumber, e.EpisodeNumber
       ;;
  }

######################################################################################

  dimension: noofepisodes {
    view_label: "Content Selection"
    group_label: "Content"
    label: "Number of Episodes OLD"
    type:  number
    description: "Dynamically calculated number of episodes for each content level"
    sql: IFNULL({%if episodes.episodenumber_IFNULL._in_query%}
         ${TABLE}.EpisodeLevel
         {%elsif episodes.seasonnumber_IFNULL._in_query%}
         ${TABLE}.SeasonLevel
        {%else%}
        ${TABLE}.TitleLevel
        {%endif%},1)
        ;;
        can_filter: no
  }






######################################################################################

  dimension: netflixid {
    type: number
    sql: ${TABLE}."NETFLIXID" ;;
    hidden: yes
  }

  dimension: seasonnumber {
    type: number
    sql: ${TABLE}."SEASONNUMBER" ;;
    hidden: yes
  }

  dimension: episodenumber {
    type: number
    sql: ${TABLE}."EPISODENUMBER" ;;
    hidden:  yes
  }

    dimension: titlelevel {
    type: number
    sql: ${TABLE}."TITLELEVEL" ;;
    view_label: "Content"
    label: "No of episodes (Title Level)"
    hidden: yes
  }

  dimension: seasonlevel {
    type: number
    sql: ${TABLE}."SEASONLEVEL" ;;
    view_label: "Content"
    label: "No of episodes (Season Level)"
    hidden: yes
  }

  dimension: episodelevel {
    type: number
    sql: ${TABLE}."EPISODELEVEL" ;;
    view_label: "Content"
    label: "No of episodes (Title Level)"
    hidden: yes
  }

}

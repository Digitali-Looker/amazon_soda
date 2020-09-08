####################
##SDR (taking from old model and modifying)
##17/02/2020
##note that this will then say what the earliest date is for a group of episodeIDs based on the combination of netflixID, SeasonNo and EpisodeNo
##and the idea is that we want the earliest date regardless of time selected
####################


view: releasedate_one {
  derived_table: {
    persist_for: "24 hours"
    sql:

  --First CTE runs minimum dates that we want to use where possible - where on the first day there were at least 4 diff diids (threshold based on viewing being delivered by at least 4 diff profiles, but can be amended)
  with uno as(
  select * from
    (select distinct
      b.netflixid,
      b.country,
      b.seasonnumber,
      b.episodenumber,
      MIN (b.date) OVER (PARTITION BY b.NetflixID,b.COUNTRY) AS MinTitleDate,
      MIN (b.date) OVER (PARTITION BY b.NetflixID, b.COUNTRY, b.SeasonNumber) AS MinTitleSeasonDate,
      MIN (b.date) OVER (PARTITION BY b.NetflixID, b.COUNTRY, b.SeasonNumber, b.EpisodeNumber) AS MinTitleSeasonEpisodeDate,
      case when b.SEASONNUMBER is null and count(distinct concat(b.Netflixid, b.seasonnumber)) OVER (PARTITION BY b.NETFLIXID,b.COUNTRY )>1 then 1 else 0 end as checktwo -- exclude those with partially missing episodeids
      FROM
      ( SELECT DISTINCT
                     pdq.diid,
                     tm.Netflixid,
                     pdq.COUNTRY,
                     pdq.date,
                     e.SEASONNUMBER ,
                     e.EPISODENUMBER,
                     count (diid) over (partition by pdq.date, tm.netflixid, e.seasonnumber, e.episodenumber, pdq.country) sessionsno,
                     count (diid) over (partition by pdq.country, tm.netflixid,e.seasonnumber, e.episodenumber) totalsessions
               from core.TitleMaster tm
                   left join core.PANELDATAINTERNATIONAL pdq
                   on tm.titleid=pdq.titleid
                       LEFT JOIN core.Episodes e
                       ON e.netflixid=tm.netflixid and ifnull(e.EpisodeID,1) = ifnull(tm.EpisodeID,1)
                                where pdq.diid is not null and tm.netflixid is not null
                       -- and tm.netflixid=80057281 and pdq.country='France' order by pdq.date
                ) b --order by a.netflixid, a.seasonnumber, a.episodenumber,a.date

        where b.sessionsno>4) c
  where c.checktwo = 0 )

  --and c.netflixid=80057281 and c.country = 'France'
  --ORDER BY c.NETFLIXID , c.SEASONNUMBER ,c.EPISODENUMBER


--------Second CTE is calculating actual minimum dates (like prev version) to cover cases where viewing is so small there isn't a single day with >4 diids or when its a tail viewing from an old release
, two as (
select * from
    (select distinct
      b.netflixid,
      b.country,
      b.seasonnumber,
      b.episodenumber,
      MIN (b.date) OVER (PARTITION BY b.NetflixID,b.COUNTRY) AS MinTitleDate,
      MIN (b.date) OVER (PARTITION BY b.NetflixID, b.COUNTRY, b.SeasonNumber) AS MinTitleSeasonDate,
      MIN (b.date) OVER (PARTITION BY b.NetflixID, b.COUNTRY, b.SeasonNumber, b.EpisodeNumber) AS MinTitleSeasonEpisodeDate,
      case when b.SEASONNUMBER is null and count(distinct concat(b.Netflixid, b.seasonnumber)) OVER (PARTITION BY b.NETFLIXID,b.COUNTRY )>1 then 1 else 0 end as checktwo -- exclude those with partially missing episodeids
      FROM
      ( SELECT DISTINCT
                     pdq.diid,
                     tm.Netflixid,
                     pdq.COUNTRY,
                     pdq.date,
                     e.SEASONNUMBER ,
                     e.EPISODENUMBER,
                     count (diid) over (partition by pdq.date, tm.netflixid, e.seasonnumber, e.episodenumber, pdq.country) sessionsno,
                     count (diid) over (partition by pdq.country, tm.netflixid,e.seasonnumber, e.episodenumber) totalsessions
               from core.TitleMaster tm
                   left join core.PANELDATAINTERNATIONAL pdq
                   on tm.titleid=pdq.titleid
                       LEFT JOIN core.Episodes e
                       ON e.netflixid=tm.netflixid and ifnull(e.EpisodeID,1) = ifnull(tm.EpisodeID,1)
                                where pdq.diid is not null and tm.netflixid is not null

                ) b --order by a.netflixid, a.seasonnumber, a.episodenumber,a.date

       ) c
  where c.checktwo = 0)
  --ORDER BY c.NETFLIXID , c.SEASONNUMBER ,c.EPISODENUMBER



  ---------Final part brings it together through coalesce (for small titles) and api release date check - if old, then everything related to season 1 will be given actual min date by default, of course there
  ---------could be cases when more than 1 season ran before our data, but there are no means of checking which seasons, for the rest of them only coalesce will play the part
  select
  two.netflixid,
  two.country,
  two.seasonnumber,
  two.episodenumber,
  case when to_date(cm.unogsdate)<two.mintitledate then two.mintitledate else coalesce (uno.MinTitleDate,two.MinTitleDate) end MinTitleDate,
  case when to_date(cm.unogsdate)<two.mintitledate and two.seasonnumber=1 then two.MinTitleSeasonDate else coalesce (uno.MinTitleSeasonDate,two.MinTitleSeasonDate) end MinTitleSeasonDate,
  case when to_date(cm.unogsdate)<two.mintitledate and two.seasonnumber=1 then two.MinTitleSeasonEpisodeDate else coalesce (uno.MinTitleSeasonEpisodeDate,two.MinTitleSeasonEpisodeDate)end MinTitleSeasonEpisodeDate

  from two
  left join uno
  on uno.netflixid=two.netflixid and uno.country=two.country and ifnull(uno.seasonnumber,1)=ifnull(two.seasonnumber,1) and ifnull(uno.episodenumber,1)=ifnull(two.episodenumber,1)
  left join core.contentmaster cm on two.netflixid=cm.netflixid

  --where two.netflixid=80057281 and two.country = 'France'
  order by two.netflixid, two. seasonnumber, two.episodenumber




       ;;
  }

#       --        Where {% condition panel_data_q3.view_date  %} pdq.date  {% endcondition  %}

################################################################################
##
################################################################################

  dimension: pk {
    type: string
    sql: concat(${netflixid},${seasonnumber}, ${episodenumber}) ;;
    primary_key: yes
    hidden:  yes
  }

  dimension: mintitledate {
    type: date
    sql: ${TABLE}."MINTITLEDATE" ;;
    hidden:  yes
  }

  dimension: mintitleseasondate {
    type: date
    sql: ${TABLE}."MINTITLESEASONDATE" ;;
    hidden:  yes
  }

  dimension: mintitleseasonepisodedate {
    type: date
    sql: ${TABLE}."MINTITLESEASONEPISODEDATE" ;;
    hidden:  yes
  }


  dimension: datefirstviewed  {
    label: "Date First Viewed"
    view_label: "Content Selection"
    group_label: "Content"
    description: "Dynamic depending on if episode, season or title are included in the query"
    type: date
    sql: {%if episodes.episodenumber_IFNULL._in_query%}
         ${TABLE}.MinTitleSeasonEpisodeDate
         {%elsif episodes.seasonnumber_IFNULL._in_query%}
         ${TABLE}.MinTitleSeasonDate
        {%else%}
        ${TABLE}.MinTitleDate
        {%endif%}
        ;;


#   {%elsif contentmaster.title_IFNULL._in_query%}
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
    sql_start: ${releasedate.datefirstviewed} ;;
    sql_end: ${ext_paneldata_fce.date_raw} ;;
    view_label: "Activity Timeframe Selection"
    group_label: "Days/ Weeks Since First Viewed"
    label: "Since First Viewed"
#     description: "Use the [Less than or Equal to] operator and enter the number of days/ weeks to see an activity time window (from when the content was first viewed plus x days/ weeks)"
    hidden: yes
    can_filter: no
  }




##################################################################################

  dimension: netflixid {
    type: number
    sql: ${TABLE}."NETFLIXID" ;;
    hidden: yes
  }

  dimension: videotype {
    type: number
    sql: ${TABLE}."VIDEOTYPE" ;;
     hidden:  yes
  }

  dimension: seasonnumber {
    type: number
    sql: ${TABLE}."SEASONNUMBER" ;;
     hidden:  yes
  }

  dimension: episodenumber {
    type: number
    sql: ${TABLE}."EPISODENUMBER" ;;
     hidden:  yes
  }

dimension: country {
  type: string
  sql: ${TABLE}."COUNTRY" ;;
  hidden: yes
}


}





# ########### OLD SCRIPT
#
#        select * from
#       (SELECT DISTINCT
#           tm.Netflixid,
#           tm.VIDEOTYPE ,
#       --    tm.TITLE ,
#             -- e.EpisodeID,
#           a.COUNTRY,
#           e.SEASONNUMBER ,
#           e.EPISODENUMBER,
#             MIN(a.MinDate) OVER (PARTITION BY tm.NetflixID,a.COUNTRY) AS MinTitleDate,
#             MIN(a.MinDate) OVER (PARTITION BY tm.NetflixID, a.COUNTRY, e.SeasonNumber) AS MinTitleSeasonDate,
#             MIN(a.MinDate) OVER (PARTITION BY tm.NetflixID, a.COUNTRY, e.SeasonNumber, e.EpisodeNumber) AS MinTitleSeasonEpisodeDate,
#             case when e.SEASONNUMBER is null and count(tm.Netflixid) OVER(PARTITION BY a.COUNTRY )>1 then 1 else 0 end as checktwo -- exclude those with partially missing episodeids
#       FROM core.TitleMaster tm
#       --       ON cm.Netflixid = tm.NetflixID
#       LEFT JOIN core.Episodes e
#              ON e.netflixid=tm.netflixid and ifnull(e.EpisodeID,1) = ifnull(tm.EpisodeID,1)
#       LEFT JOIN
#          (
#              SELECT pdq.TitleID, pdq.country,
#                     MIN(Date) AS MinDate
#              FROM core.PANELDATAINTERNATIONAL pdq
#              GROUP BY pdq.TitleID, pdq.country
#          ) a
#              ON a.TitleID = tm.TitleID
#               WHERE tm.NetflixID IS NOT NULL) one  --note in the model this is already accounted for but is for processing optimisation
#               where one.checktwo = 0
#        ORDER BY one.NETFLIXID ,   one.SEASONNUMBER ,one.EPISODENUMBER

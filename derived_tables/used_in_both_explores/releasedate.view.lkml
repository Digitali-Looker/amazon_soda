view: releasedate {
  derived_table: {
    persist_for: "24 hours"
    sql:
    select * from
    (select distinct
      b.netflixid,
      b.country,
      b.seasonnumber,
      b.episodenumber,
     -- count(distinct concat(b.Netflixid, b.seasonnumber)) CHECK1,
      --count(distinct concat(b.Netflixid, b.seasonnumber)) OVER (PARTITION BY b.NETFLIXID,b.COUNTRY ) check2
      MIN (b.date) OVER (PARTITION BY b.NetflixID,b.COUNTRY) AS MinTitleDate,
      MIN (b.date) OVER (PARTITION BY b.NetflixID, b.COUNTRY, b.SeasonNumber) AS MinTitleSeasonDate,
      MIN (b.date) OVER (PARTITION BY b.NetflixID, b.COUNTRY, b.SeasonNumber, b.EpisodeNumber) AS MinTitleSeasonEpisodeDate,
      case when b.SEASONNUMBER is null and count(distinct concat(b.Netflixid, b.seasonnumber)) OVER (PARTITION BY b.NETFLIXID,b.COUNTRY )>0 then 1 else 0 end as checkthree -- exclude those with partially missing episodeids
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
                       ON e.netflixid=tm.netflixid and ifnull(e.EpisodeID,'1') = ifnull(tm.EpisodeID,'1')
                                where pdq.diid is not null and tm.netflixid is not NULL
                                --AND tm.NETFLIXID =80148535 AND pdq.country='UK'

                ) b --order by a.netflixid, a.seasonnumber, a.episodenumber,a.date
                --GROUP BY 1,2,3,4

       ) c
  where c.checkthree = 0




    ;;

 }



################################################################################
##
################################################################################

  dimension: pk {
    type: string
    sql: concat(${netflixid},${country}, ${seasonnumber}, ${episodenumber}) ;;
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






##################################################################################

  dimension: netflixid {
    type: string
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

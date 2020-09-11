###############################
## DS 03/03/20
## This PDT is to supply Dynamic Content Name with pre-created options for all 3 levels of granularity
##################################



view: title_lookup {
  derived_table: {
     persist_for: "24 hours"
    sql: SELECT
          ROW_NUMBER() OVER (ORDER BY tm.TitleID) AS RowNo ,
          tm.TitleID,
             cm.Netflixid,
             e.EpisodeID,
             cm.Title AS TitleOnly,
             CASE
                 WHEN e.Netflixid IS NULL THEN
                     cm.Title
                 ELSE
                     CONCAT(cm.Title, ' - S', trim(to_char(ifnull(e.SeasonNumber,1),'00')))
             END AS TitleSeason,
             CASE
                 WHEN e.Netflixid IS NULL THEN
                     cm.Title
                 ELSE
                     CONCAT(
                               cm.Title,
                               ' - S',
                               trim(to_char(ifnull(e.SeasonNumber,1),'00')),
                               ' E',
                              trim(To_char(ifnull(e.EpisodeNumber,1),'9900'))
                           )
             END AS TitleSeasonEpisode,
            ----------Added part to replace numberofepisodes PDT
              count ( distinct CASE
                                   WHEN e.Netflixid IS NULL THEN
                                       cm.Title
                                   ELSE
                                       CONCAT(
                                                 cm.Title,
                                                 ' - S',
                                                 trim(to_char(ifnull(e.SeasonNumber,1),'00')),
                                                 ' E',
                                                trim(To_char(ifnull(e.EpisodeNumber,1),'9900'))
                                             )
                                  END) over (partition by cm.netflixid) counttitlelevel,
              count ( distinct CASE
                                   WHEN e.Netflixid IS NULL THEN
                                       cm.Title
                                   ELSE
                                       CONCAT(
                                                 cm.Title,
                                                 ' - S',
                                                 trim(to_char(ifnull(e.SeasonNumber,1),'00')),
                                                 ' E',
                                                trim(To_char(ifnull(e.EpisodeNumber,1),'9900'))
                                             )
                                  END) over (partition by cm.netflixid, ifnull(e.seasonnumber,1)) countseasonlevel,
              count ( distinct CASE
                                   WHEN e.Netflixid IS NULL THEN
                                       cm.Title
                                   ELSE
                                       CONCAT(
                                                 cm.Title,
                                                 ' - S',
                                                 trim(to_char(ifnull(e.SeasonNumber,1),'00')),
                                                 ' E',
                                                trim(To_char(ifnull(e.EpisodeNumber,1),'9900'))
                                             )
                                  END) over (partition by cm.netflixid, ifnull(e.seasonnumber,1), ifnull(e.episodenumber,1)) countepisodelevel
      --INTO core.TitleLookUp
      FROM core.TitleMaster tm
          LEFT JOIN core.ContentMaster cm
              ON cm.Netflixid = tm.NetflixID
          LEFT JOIN core.Episodes e
              ON e.EpisodeID = tm.EpisodeID
      WHERE tm.NetflixID IS NOT NULL
       ;;
    #indexes: ["TitleID"]
  }


  dimension: row_no {
    primary_key: yes
    type: number
    sql: ${TABLE}.RowNo ;;
    hidden: yes
  }

  dimension: title_id {
    type: number
    sql: ${TABLE}.TitleID ;;
    hidden: yes
  }

  dimension: netflixid {
    type: string
    sql: ${TABLE}.Netflixid ;;
    hidden: yes
  }

  dimension: episode_id {
    type: string
    sql: ${TABLE}.EpisodeID ;;
    hidden: yes
  }

  dimension: titleonly {
    type: string
    sql: ${TABLE}.TitleOnly ;;
    #hidden: yes
    label: "Content (Title Level)"
    view_label: "Content Selection"
    group_label: "Cumulative Reach"
    description: "Use when need a filter that is not dependent on the granularity level parameter"
  }

  dimension: titleseason {
    type: string
    sql: ${TABLE}.TitleSeason ;;
    #hidden: yes
    label: "Content (Season Level)"
    view_label: "Content Selection"
    group_label: "Cumulative Reach"
    description: "Use when need a filter that is not dependent on the granularity level parameter"
  }

  dimension: titleseasonepisode {
    type: string
    sql: ${TABLE}.TitleSeasonEpisode ;;
    #hidden: yes
    label: "Content (Episode Level)"
    view_label: "Content Selection"
    group_label: "Cumulative Reach"
    description: "Use when need a filter that is not dependent on the granularity level parameter"
  }

  dimension: titleseason_fce {
    type: string
    sql: ${TABLE}.TitleSeason ;;
    label: "Title - Season"
    view_label: "Content Selection"
    group_label: "Content"

  }

  dimension: titleonly_fce {
    type: string
    sql: ${TABLE}.TitleOnly ;;
    label: "Title Only"
    view_label: "Content Selection"
    group_label: "Content"
    hidden: yes

  }

  dimension: titleseasonepisode_fce {
    type: string
    sql: ${TABLE}.TitleSeasonEpisode ;;
    label: "Title - Season - Episode"
    view_label: "Content Selection"
    group_label: "Content"
    hidden: yes

  }

  dimension: counttitlelevel {
    type: number
    hidden: yes
  }

  dimension: countseasonlevel {
    type: number
    hidden: yes
  }

  dimension: countepisodelevel {
    type: number
    hidden: yes
  }



}

##############################
##SDR
##18/02/2020
##Reach - can apply frequency by changing the =1 to whatever row number you want
##############################


view: reach {
  derived_table: {
    sql: WITH filter_CTE AS
      (
      SELECT
                   pdq.DiID
                           , pdq.RespondantID
                           , pdq.Date
                           , pdq.PersonKey
                 , tm.VIDEOTYPE
                           , tm.NetflixID
                           , e.SeasonNumber
                           , e.EpisodeNumber
      --
                 ,ROW_NUMBER() OVER(PARTITION BY pdq.RespondantID,tm.Netflixid ORDER BY date) AS RIDsXTitle
                 ,ROW_NUMBER() OVER(PARTITION BY pdq.RespondantID,tm.netflixid, e.SeasonNumber ORDER BY date) AS RIDsXTitleSeason
                 ,ROW_NUMBER() OVER(PARTITION BY pdq.RespondantID,tm.netflixid, e.SeasonNumber, e.EpisodeNumber ORDER BY date) AS RIDsXTitleSeasonEpisode
      --
                           , hd.DemoID
                           , hd.SEC
                           , hd.SECGroup
                           , hd.KidsGroup
                           , hd.HouseholdSize
                           , hd.HousholdPlatform
                           , hd.AccountHolderAgeGroup
                           , hd.AccountHolderGender
                           , fw.thousandsweight
      FROM            core.PanelData pdq
          LEFT JOIN   core.TitleMaster tm
                 ON   tm.TitleID = pdq.TitleID
          LEFT JOIN   core.ContentMaster cm --NEED THIS FOR THE SERIES OR MOVIE TITLE
                 ON   cm.Netflixid = tm.NetflixID
          LEFT JOIN   core.Episodes e
                 ON   e.EpisodeID = tm.EpisodeID --NEED TITLE MASTER in order to get the episode level that has been split out- otherwise will be just the full title (which includes title and episode name)
          ----------------------------------------------------------------------------------------------------------------------------------------------------------------
          LEFT JOIN   core.HouseholdDemo hd
                 ON   pdq.RespondantID = hd.RID
          LEFT JOIN   core.FinalWeights fw
                 ON   fw.DemoID = hd.DemoID
                      AND fw.PanelYear = YEAR(pdq.Date)
                      AND fw.PanelQuarter = QUARTER(PDQ."DATE" )
      WHERE       {% condition paneldata.date_raw  %} pdq.date  {% endcondition  %}
      --DEMO FILTERS
      ORDER BY RESPONDANTID ,netflixID
      )
      SELECT DISTINCT
           videotype
          ,NetflixID
          ,SeasonNumber
          ,EpisodeNumber
      --ENTER PARAMETERISED VALUE IN =1 TO GET THE FREQUENCY REQUIRED
          ,SUM(CASE WHEN RidsXTitle               = {%parameter reachfrequency %} THEN 1 ELSE 0 END) OVER(PARTITION BY NETFLIXID) AS TitleReachCount
          ,SUM(CASE WHEN RidsXTitleSeason         = {%parameter reachfrequency %} THEN 1 ELSE 0 END) over(PARTITION BY netflixid, seasonnumber) AS TitleSeasonReachCount
          ,SUM(CASE WHEN RidsXTitleSeasonEpisode  = {%parameter reachfrequency %} THEN 1 ELSE 0 END) over(PARTITION BY netflixid, seasonnumber, episodenumber) AS TitleSeasonEpisodeReachCount
      --
          ,SUM(CASE WHEN RidsXTitle               = {%parameter reachfrequency %} THEN ThousandsWeight ELSE 0 END) OVER(PARTITION BY NETFLIXID) AS TitleReach
          ,SUM(CASE WHEN RidsXTitleSeason         = {%parameter reachfrequency %} THEN ThousandsWeight ELSE 0 END) over(PARTITION BY netflixid, seasonnumber) AS TitleSeasonReach
          ,SUM(CASE WHEN RidsXTitleSeasonEpisode  = {%parameter reachfrequency %} THEN ThousandsWeight ELSE 0 END) over(PARTITION BY netflixid, seasonnumber, episodenumber) AS TitleSeasonEpisodeReach
      FROM FILTER_CTE
      ORDER BY netflixid, seasonnumber, episodenumber
       ;;
  }

##########################################################################

parameter: reachfrequency {
  type: number
  default_value: "1"
  view_label: "Reach"
  label: "Reach Frequency"
  hidden: yes
  }

  dimension: titlereach {
    type: number
    sql: ${TABLE}."TITLEREACH" ;;
    hidden: yes
  }

  dimension: titleseasonreach {
    type: number
    sql: ${TABLE}."TITLESEASONREACH" ;;
    hidden: yes
  }

  dimension: titleseasonepisodereach {
    type: number
    sql: ${TABLE}."TITLESEASONEPISODEREACH" ;;
    hidden: yes
  }


  dimension: reach000s  {
    view_label: "Reach"
    label: "Reach 000s"

    description: "Dynamic Reach depending on if episode, season or title are included in the query"
    type: number
    sql: {%if episodes.episodenumber_IFNULL._in_query %}
         ${TABLE}.titleseasonepisodereach
         {%elsif episodes.seasonnumber_IFNULL._in_query %}
         ${TABLE}.titleseasonreach
         {%else%}
        ${TABLE}.titlereach
        {%endif%}
        ;;
    value_format: "#,##0"
    hidden: yes
    }


###########################################################################

  dimension: videotype {
    type: number
    sql: ${TABLE}."VIDEOTYPE" ;;
    hidden:  yes
  }

  dimension: netflixid {
    type: number
    sql: ${TABLE}."NETFLIXID" ;;
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

  dimension: titlereachcount {
    type: number
    sql: ${TABLE}."TITLEREACHCOUNT" ;;
    hidden:  yes
  }

  dimension: titleseasonreachcount {
    type: number
    sql: ${TABLE}."TITLESEASONREACHCOUNT" ;;
    hidden:  yes
  }

  dimension: titleseasonepisodereachcount {
    type: number
    sql: ${TABLE}."TITLESEASONEPISODEREACHCOUNT" ;;
    hidden:  yes
  }



}

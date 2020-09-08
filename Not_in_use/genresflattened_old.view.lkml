##########################
##SDR
##19/02/2020
##This takes from core.TitleGenres and gets the most popular to assign to the netflix ID, knocking out Other as the primary one where it can
##########################


view: genresflattened_old {
  derived_table: {
    persist_for: "24 hours"
    sql: WITH GenrePrep_CTE AS
      (
           SELECT NetflixID
         , IFNULL(Genre, 'Other') AS Genre
            FROM core.TitleGenres tg
                group by Netflixid,IFNULL(Genre, 'Other')
        order by netflixid
      --ORDER BY ISNULL(Genre, 'Other')
      )
      ,GenrePopularity AS
      (
      SELECT Genre
         , COUNT(*) AS count
      FROM GenrePrep_CTE tg
      GROUP BY tg.Genre
      )
      --SELECT *
      --FROM GenrePopularity
      --
      --
      ,prep_STUFF_cte AS
      (
      SELECT NetflixID,
      LISTAGG(concat( Genre, ', ')) WITHIN GROUP (ORDER BY Genre) AS LIST
      --LISTAGG(Genre) WITHIN GROUP (ORDER BY Genre) AS LIST
      FROM GenrePrep_CTE
      GROUP BY Netflixid
      )
      --SELECT * FROM prep_STUFF_cte
      --
      ,prep_cte AS
      (
      SELECT G.NetflixID
          ,LEFT(LIST,(LENGTH(STUFF.LIST)-2)) AS AllGenresStuffed
          ,G.GENRE
          ,POP.Count
          ,ROW_NUMBER() OVER(PARTITION BY G.NetflixID ORDER BY POP.Count desc) AS ROWNO
          ,COUNT(G.Genre) OVER(PARTITION BY G.NETFLIXID) AS NumberOfGenres
      FROM GenrePrep_CTE G
      LEFT JOIN prep_STUFF_cte STUFF
      ON G.NETFLIXID = STUFF.NETFLIXID
      LEFT JOIN GenrePopularity POP
      ON G.Genre = POP.Genre
      ORDER BY NETFLIXID
      )
      --
      ,prep2_CTE AS
      (
      SELECT *
      ,CASE WHEN NumberOfGenres = 1 THEN 1
            WHEN numberOfGenres >1 AND (rowno = 1 AND (genre like '%Other%' or genre = 'US TV Programmes')) THEN 0
            WHEN numberOfGenres >1 AND (rowno = 2 AND (ALLGENRESSTUFFED NOT LIKE '%Other%')) THEN 0
            WHEN numberOfGenres >2 AND rowno>2 THEN 0
          ELSE 1
          END AS OneToTakeFlag
      ,SUM(CASE WHEN NumberOfGenres = 1 THEN 1
            WHEN numberOfGenres >1 AND (rowno = 1 AND (genre like '%Other%' or genre = 'US TV Programmes')) THEN 0
            WHEN numberOfGenres >1 AND (rowno = 2 AND (ALLGENRESSTUFFED NOT LIKE '%Other%')) THEN 0
            WHEN numberOfGenres >2 AND rowno>2 THEN 0
          ELSE 1
          END) OVER (PARTITION BY NETFLIXID) AS TotalFlags


      FROM prep_cte
      )
      --SELECT *
      --FROM prep2_cte
      --WHERE prep2_CTE.OneToTakeFlag = 1
      --ORDER BY NetflixID
      ----, count desc
      SELECT NetflixID , AllGenresStuffed, Genre, Count
      FROM prep2_cte
      WHERE prep2_CTE.OneToTakeFlag = 1
      ORDER BY NetflixID
      --, count desc
      --ORDER BY prep2_CTE.TotalFlags asc;
       ;;
  }

  ########################################################

  dimension: allgenreclassifications {
    type: string
    sql: ${TABLE}."ALLGENRESSTUFFED" ;;
    view_label: "Content Selection"
    group_label: "Genre"
    label: "All Genres Associated with Content"
    can_filter: no
  }


  dimension: genre {
    type: string
    #sql: ${TABLE}."GENRE"  ;;
    sql: case when ${TABLE}."GENRE" = 'US TV Programmes' then 'Other' else ${TABLE}."GENRE" end ;;
    ##DS 020320 this is a temporary measure to exclude US Programmes from the list, should be done at the titlegenres table creation level
    view_label: "Content Selection"
    group_label: "Genre"
    label: "Primary Genre"
  }

  #######################################################
  dimension: netflixid {
    type: number
    sql: ${TABLE}."NETFLIXID" ;;
    hidden: yes
  }


  dimension: genrepopularitycount {
    type: number
    sql: ${TABLE}."COUNT" ;;
    hidden: yes
  }


}


#########################
#DS 020320 old script - wasn't calculating correctly as was taking second best genre for those titles without Other in the list
#########################
#       SELECT *
#       ,CASE WHEN NumberOfGenres = 1 THEN 1
#             WHEN numberOfGenres >1 AND (rowno = 1 AND genre = 'Other') THEN 0
#             WHEN numberOfGenres >1 AND (rowno = 1 AND genre <> 'Other') THEN 0
#           WHEN numberOfGenres >2 AND rowno>2 THEN 0
#           ELSE 1
#           END AS OneToTakeFlag
#       ,SUM(CASE WHEN NumberOfGenres = 1 THEN 1
#             WHEN numberOfGenres >1 AND (rowno = 1 AND genre = 'Other') THEN 0
#             WHEN numberOfGenres >1 AND (rowno = 1 AND genre <> 'Other') THEN 0
#           WHEN numberOfGenres >2 AND rowno>2 THEN 0
#           ELSE 1
#           END) OVER (PARTITION BY NETFLIXID) AS TotalFlags

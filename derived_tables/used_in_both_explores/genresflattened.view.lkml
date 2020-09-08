##BASE TABLES ARE NOT AVAILABLE YET FOR AMAZON

# ##########################
# ##SDR
# ##19/02/2020
# ##This takes from core.TitleGenres and gets the most popular to assign to the netflix ID, knocking out Other as the primary one where it can
# ##########################
#
#
# view: genresflattened {
#   derived_table: {
#     persist_for: "24 hours"
#     sql: WITH GenrePrep_CTE AS
#       (
#            SELECT NetflixID
#          , IFNULL(Genre, 'Other') AS Genre
#             FROM core.TitleGenres tg
#                 group by Netflixid,IFNULL(Genre, 'Other')
#         order by netflixid
#       --ORDER BY ISNULL(Genre, 'Other')
#       )
#       ,GenrePopularity AS
#       (
#       WITH one AS (
# SELECT *, ROW_NUMBER() OVER (PARTITION BY NETFLIXID  ORDER BY genrerank) rowno FROM core.TITLEGENRES a
# LEFT JOIN core.GenreRank b ON a.GENRE  = b.GenreName
# )
# SELECT NETFLIXID, GENRE FROM one WHERE rowno = 1
#       )
#       ,prep_STUFF_cte AS
#       (
#       SELECT NetflixID,
#       LISTAGG(concat( Genre, ', ')) WITHIN GROUP (ORDER BY Genre) AS LIST
#       --LISTAGG(Genre) WITHIN GROUP (ORDER BY Genre) AS LIST
#       FROM GenrePrep_CTE
#       GROUP BY Netflixid
#       )
#       select a.NETFLIXID, a.GENRE ,
#       LEFT(LIST,(LENGTH(b.LIST)-2)) AS ALLGENRESSTUFFED from GenrePopularity a
#       LEFT JOIN prep_STUFF_cte b ON a.NETFLIXID  = b.NetflixID
#
#       --, count desc
#       --ORDER BY prep2_CTE.TotalFlags asc;
#        ;;
#   }
#
#   ########################################################
#
#    dimension: allgenreclassifications {
#     type: string
#     sql: ${TABLE}."ALLGENRESSTUFFED" ;;
#     view_label: "Content Selection"
#     group_label: "Genre"
#     label: "All Genres Associated with Content"
#     can_filter: no
#   }
#
#
#   dimension: genre {
#     type: string
#     #sql: ${TABLE}."GENRE"  ;;
#     sql: IFNULL(${TABLE}."GENRE",'Other')  ;;
#     ##DS 020320 this is a temporary measure to exclude US Programmes from the list, should be done at the titlegenres table creation level
#     view_label: "Content Selection"
#     group_label: "Genre"
#     label: "Primary Genre"
#   }
#
#   #######################################################
#   dimension: netflixid {
#     type: number
#     sql: ${TABLE}."NETFLIXID" ;;
#     hidden: yes
#   }
#
#
#   dimension: genrepopularitycount {
#     type: number
#     sql: ${TABLE}."COUNT" ;;
#     hidden: yes
#   }
#
#
# }
#
#
# #########################
# #DS 020320 old script - wasn't calculating correctly as was taking second best genre for those titles without Other in the list
# #########################
# #       SELECT *
# #       ,CASE WHEN NumberOfGenres = 1 THEN 1
# #             WHEN numberOfGenres >1 AND (rowno = 1 AND genre = 'Other') THEN 0
# #             WHEN numberOfGenres >1 AND (rowno = 1 AND genre <> 'Other') THEN 0
# #           WHEN numberOfGenres >2 AND rowno>2 THEN 0
# #           ELSE 1
# #           END AS OneToTakeFlag
# #       ,SUM(CASE WHEN NumberOfGenres = 1 THEN 1
# #             WHEN numberOfGenres >1 AND (rowno = 1 AND genre = 'Other') THEN 0
# #             WHEN numberOfGenres >1 AND (rowno = 1 AND genre <> 'Other') THEN 0
# #           WHEN numberOfGenres >2 AND rowno>2 THEN 0
# #           ELSE 1
# #           END) OVER (PARTITION BY NETFLIXID) AS TotalFlags

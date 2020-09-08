###################################################
##SDR
##15/06/2020
##This is a nice table that is refreshed by the Python script at the point of Title matching refresh of contentmaster and episodes (is part of a sproc in public.ADDTOCORE())
###################################################

view: imdbinfo {
  sql_table_name: "CORE"."IMDBINFO"
    ;;

    view_label: "Content Selection"

##############################################

  dimension: actor {
    type: string
    sql: ${TABLE}."ACTOR" ;;
    group_label: "Content Meta Data"
    label: "IMDb Actors"
  }

  dimension: awards {
    type: string
    sql: ${TABLE}."AWARDS" ;;
    group_label: "Content Meta Data"
    label: "IMDb Awards"

  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
    group_label: "Content Meta Data"
    label: "IMDb Countries of Origin"
    description: "IMDb defines the country of a title as the place or places where the production companies for that title are based, and therefore where the financing originated.
                  This means, for example, even if a title is shot on location in France, if its production companies are all based in the USA, IMDb records the country as USA."
  }


  dimension: firstcountry {
    type: string
    map_layer_name: countries
    ##sql:trim(SPLIT_PART(${TABLE}."COUNTRY",',',1))  ;;
   sql: coalesce(${TABLE}."PRIMARYCOUNTRYOVERRIDE",trim(SPLIT_PART(${TABLE}."COUNTRY",',',1))) ;;
    group_label: "Content Meta Data"
    label: "IMDb Primary Country of Origin"
    description: "This will show you the first Country in the list of Countries of Origin. IMDb defines the country of a title as the place or places where the production companies
    for that title are based, and therefore where the financing originated. This means, for example, even if a title is shot on location in France, if its production companies are all
    based in the USA, IMDb records the country as USA."
  }

  ##SDR 29/06/2020
  dimension: PrimaryCountryOverride {
    sql: ${TABLE}."PRIMARYCOUNTRYOVERRIDE" ;;
    hidden: yes
#     group_label: "Content Meta Data"
#     label: "TEST IMDb Primary Country Override"
  }

  dimension: creator {
    type: string
    sql: ${TABLE}."CREATOR" ;;
    group_label: "Content Meta Data"
    label: "IMDb Creator"
  }


  dimension: director {
    type: string
    sql: ${TABLE}."DIRECTOR" ;;
    group_label: "Content Meta Data"
    label: "IMDb Director"
  }

  dimension: genre {
    type: string
    sql: ${TABLE}."GENRE" ;;
    group_label: "Genre"
    label: "IMDb Genre"
  }

  dimension: imdbid {
    type: string
    sql: ${TABLE}."IMDBID" ;;
    group_label: "Content Meta Data"
    label: "IMDb ID"
  }

  dimension: language {
    type: string
    sql: ${TABLE}."LANGUAGE" ;;
    group_label: "Content Meta Data"
    label: "IMDb Language"
    description: "The IMDb languages section records the languages spoken within the title."
  }

  dimension: metascore {
    type: string
    sql: ${TABLE}."METASCORE" ;;
    group_label: "Content Meta Data"
    label: "IMDb Meta Score"
    description: "IMDb defines 'Metascore' as the rating of a film.
                  Scores are assigned to movie's reviews of large group of the world's most respected critics, and weighted average are applied to summarize their opinions range.
                  The result is shown in single number that captures the essence of critical opinion in one Metascore."
  }

  dimension: plot {
    type: string
    sql: ${TABLE}."PLOT" ;;
    group_label: "Content Meta Data"
    label: "IMDb Plot"
  }

  dimension: rating {
    type: number
    sql: ${TABLE}."RATING" ;;
    group_label: "Content Meta Data"
    label: "IMDb Rating"
    description: "IMDb registered users can cast a vote (from 1 to 10) on every released title in the database.
                  Individual votes are then aggregated and summarized as a single IMDb rating."
    value_format: "0.##"

  }

  dimension: votes {
    type: string
    sql: ${TABLE}."VOTES" ;;
    group_label: "Content Meta Data"
    label: "IMDb No of Votes"
    description: "This tells us the number of people who have contributed towards the IMDb Rating"
  }

   dimension: runtime {
    type: string
    sql: ${TABLE}."RUNTIME" ;;
    group_label: "Content Meta Data"
    label: "IMDb Runtime"
    description: "The IMDb running times records the duration in minutes of titles. For theatrical releases the timing begins from the first distributor logo
                  and ends at the last frame of the end credits."
  }


##############################################

    dimension: netflixid {
    type: string
    sql: ${TABLE}."NETFLIXID" ;;
    hidden:  yes
  }

  dimension: itemid {
    type: number
    value_format_name: id
    sql: ${TABLE}."ITEMID" ;;
    hidden: yes
    primary_key: yes
  }
}

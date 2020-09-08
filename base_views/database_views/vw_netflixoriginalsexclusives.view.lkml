####################
##TF and SDR
##11/08/2020
##This is a view that has joined the table core.NetflixOriginalsExclusives to TM and to episodes for series and this table to TM and Content Master for Movies, then Unions
####################



  view: vw_netflixoriginalsexclusives {
    sql_table_name: "CORE"."VW_NETFLIXORIGINALSEXCLUSIVES"
      ;;

    view_label: "Content Selection"

#####################################################################
##Dimensions
#####################################################################

##############################
##top level info
##############################

 dimension: netflixid {
      type: number
      value_format_name: id
      sql: ${TABLE}."NETFLIXID" ;;
      hidden: yes
    }

  dimension: videotype {
      type: string
      sql: ${TABLE}."VIDEOTYPE" ;;
      hidden: yes
    }

  dimension: title {
      type: string
      sql: ${TABLE}."TITLE" ;;
      hidden: yes
    }

  dimension: titleid {
      type: number
      value_format_name: id
      sql: ${TABLE}."TITLEID" ;;
      hidden: yes
    }
  dimension: isbothoriginalandexclusive {
      type: yesno
      sql: ${TABLE}."ISBOTHORIGINALANDEXCLUSIVE" = 1 ;;
    group_label: "Originals/ Exclusives/ Acquired Breakdown"
        label: "Comprises Original and Exclusive Seasons"
    description: "Some series will have been an Exclusive for some seasons and a Netflix Original for some seasons, so this flags those that have been both"
       hidden: yes ##SDR 18/08/2020 following MR Request
    }

  dimension: latestclassification {
      type: string
      sql: CASE WHEN IsContinuation = 1 THEN 'Continuation' WHEN IsCoproduction = 1 THEN 'Co-Production' ELSE (coalesce(${TABLE}."LATESTCLASSIFICATION",'Acquired')) END ;;
#     group_label: "Originals/ Exclusives/ Acquired Breakdown"
      group_label: "Content Classification"
    label: "Title Classification"   ##SDR 18/08/2020 from Latest Classification
     ## description: "If this is a series that has Original/ Exclusive classifications, then this will show the classification of the latest series- if it hasn't been either of these classifications, then will show as 'Acquired'"
    description: "Classifies each Title as Original, Exclusive, Continuation, Co-Production or Acquired"
    }

##############################
##Coproduction
##############################

    dimension: iscoproduction {
      type: yesno
      sql: ${TABLE}."ISCOPRODUCTION" = 1 ;;
      group_label: "Originals/ Exclusives/ Acquired Breakdown"
      label: "Is a Co-Production"
      hidden: yes ##SDR 20/08/2020 MR request

    }

    dimension: coproductioncompany {
      type: string
      sql: ${TABLE}."COPRODUCTIONCOMPANY" ;;
      group_label: "Originals/ Exclusives/ Acquired Breakdown"
      label: "Co-Production Company"
      hidden: yes ##SDR 18/08/2020 following MR request
    }

##############################
##Exclusive
##############################

    dimension: isexclusive {
      type: yesno
      sql: ${TABLE}."ISEXCLUSIVE" = 1 ;;
      group_label: "Originals/ Exclusives/ Acquired Breakdown"
      label: "Is an Exclusive"
       hidden: yes ##SDR 20/08/2020 MR request
    }

    dimension: exclusiveregion {
      type: string
      sql: ${TABLE}."EXCLUSIVEREGION" ;;
      group_label: "Originals/ Exclusives/ Acquired Breakdown"
      label: "Exclusive Region(s)"
      hidden: yes ##SDR 18/08/2020 following MR request
    }

##############################
##Continuation
##############################

    dimension: seasonnumber {
      type: number
      sql: ${TABLE}."SEASONNUMBER" ;;
      hidden: yes
    }

    dimension: iscontinuation {
      type: yesno
      sql: ${TABLE}."ISCONTINUATION" =1 ;;
      group_label: "Originals/ Exclusives/ Acquired Breakdown"
      label: "Is a Continuation"
       hidden: yes ##SDR 20/08/2020 MR request
    }

      ##MR says 17/08/2020 - he likes this but to think about expanding out to acquired too - we'll need to have a think on how this works
    dimension: overallpreviousnetwork {
      type: string
      sql: ${TABLE}."OVERALLPREVIOUSNETWORK" ;;
#       group_label: "Originals/ Exclusives/ Acquired Breakdown"
      group_label: "Content Classification"
#       label: "Previous Network (Continuations Only)"
        label: "Title Other Network" ##SDR 20/08/2020 MR request
      description: "If this is a Continuation or an Exclusive this will state the previous or other network the content was on"
    }

    dimension: seasonlevelnetwork {
      type: string
      sql: ${TABLE}."PREVIOUSANDCURRENTNETWORKS" ;;   ##SDR 20/08/2020
#       group_label: "Originals/ Exclusives/ Acquired Breakdown"
      group_label: "Content Classification"
      label: "Season Network"
#       description: "If you bring season into the query and this is a continuation, then this will show you the networks the different seasons were on"
description: "Use alongside season number to see what network each individual season of a programme was on"
#       html: {% if episodes.seasonnumber_IFNULL._is_selected %}
#                       {{value}}
#                       {% else %} Please add in season number to view the season level network
#                       {% endif %} ;;
hidden: yes ##SDR 20/08/2020 MR request until we fill this all out!
             }


    dimension: seasonlevelclassification {
      type: string
#       sql: ${TABLE}."SEASONCLASSIFICATION" ;;
#       sql: coalesce(${TABLE}."SEASONCLASSIFICATION",'Acquired') ;;    ##SDR 18/08/2020
#       sql: CASE WHEN IsContinuation = 1 THEN 'Continuation' ELSE (coalesce(${TABLE}."SEASONCLASSIFICATION",'Acquired')) END ;; ##SDR 19/08/2020
      sql: coalesce(${TABLE}."SEASONCLASSIFICATION",'Acquired');; ##SDR 19/08/2020
#       group_label: "Originals/ Exclusives/ Acquired Breakdown"
      group_label: "Content Classification"
      label: "Season Classification"
#       description: "If you bring season into the query and this is a continuation, then this will show you if the season was Acquired, an Exclusive or an Original"
description: "Use alongside season number to see the classification for each individual season of a programme"
#       html: {% if episodes.seasonnumber_IFNULL._is_selected %}
#       {{value}}
#       {% else %} Please add in season number to view the season level classification
#       {% endif %} ;;
    }

  }

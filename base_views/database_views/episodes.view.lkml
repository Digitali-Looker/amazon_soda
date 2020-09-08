#############################
##13/02/2020
##TF
#############################

view: episodes {
  sql_table_name: "CORE"."EPISODES"
    ;;
  drill_fields: [episodeid]
  view_label: "Content Selection"

    #########################################################################

    dimension: episode_title {
    type: string
    sql: IFNULL(${TABLE}."TITLE",'') ;;
    group_label: "Content"
      label: "Episode Name"
      hidden:  yes ##DS suggested to remove this for now until we've sorted coding errors
  }
  ##---------------------------------------------------------------------------
    dimension: episodenumber {
    type: number
    sql: ${TABLE}."EPISODENUMBER" ;;
    hidden: yes
  }

    dimension: episodenumber_IFNULL {
    type: string
    sql: IFNULL(CAST(${episodenumber} AS VARCHAR(1000)),'') ;;
    group_label: "Content"
    label: "Episode Number"
    order_by_field: episodenumber

  }



  ##---------------------------------------------------------------------------

    dimension: seasonnumber {
    type: number
    sql: ${TABLE}."SEASONNUMBER" ;;
    hidden: yes
  }

  dimension: seasonnumber_IFNULL {
    type: string
    sql: IFNULL(CAST(${seasonnumber} AS VARCHAR(1000)),'') ;;
    group_label: "Content"
    label: "Season Number"
    order_by_field: seasonnumber

  }

    #########################################################################

  dimension: episodeid {
    primary_key: yes
    type: string
    sql: ${TABLE}."EPISODEID" ;;
    hidden: yes
  }

  dimension: autogen {
    type: number
    sql: ${TABLE}."AUTOGEN" ;;
    hidden: yes
  }

  dimension: image {
    type: string
    sql: ${TABLE}."IMAGE" ;;
    hidden: yes
  }

  dimension: itemid {
    type: number
    value_format_name: id
    sql: ${TABLE}."ITEMID" ;;
    hidden: yes
  }

  dimension: netflixid {
    type: number
    value_format_name: id
    sql: ${TABLE}."NETFLIXID" ;;
    hidden: yes
  }

  dimension: synopsis {
    type: string
    sql: ${TABLE}."SYNOPSIS" ;;
    hidden: yes
  }




}

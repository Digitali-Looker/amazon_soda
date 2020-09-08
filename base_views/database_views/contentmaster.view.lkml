#############################
##13/02/2020
##TF
##14/02/2020
##SDR
#############################

view: contentmaster {
  sql_table_name: "CORE"."CONTENTMASTER"
    ;;
view_label: "Content Selection"

  #########################################################################

##SDR 15/06/2020 - removed as this isnt IMDB rating, this is something else :) and pointing IMDB rating label to core.IMDBInfo
#   dimension: rating {
#     type: string
#     sql: ${TABLE}."RATING" ;;
#     group_label: "Content Meta Data"
#     label: "IMDB Rating"
#     hidden: yes
#   }

  dimension: released {
    type: string
    sql: ${TABLE}."RELEASED" ;;
    group_label: "Content Meta Data"
    label: "Original Release Date"
    description: "This is the original release date of the title (according to Netflix)"   ##SDR 15/06/2020 - changed from "According to IMDb"
    can_filter: no
  }

##SDR 15/06/2020 - removed this as we have an IMDb minutes
#   dimension: runtime {
#     type: string
#     sql: ${TABLE}."RUNTIME" ;;
#     group_label: "Content Meta Data"
#     label: "Run Time"
#     can_filter: no
#     hidden: yes
#   }

  dimension: synopsis {
    type: string
    sql: ${TABLE}."SYNOPSIS" ;;
    group_label: "Content Meta Data"
    label: "Synopsis"
    description: "This is a brief summary of the plot (according to Netflix)"
    can_filter: no
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
    group_label: "Content"
    label: "Title"

  }

   dimension: screenshot {
    sql: IFNULL(${largeimage},${image}) ;;
    html: <img src={{value}} height=400 /> ;;
    group_label: "Content Meta Data"
    label: "Image"
#     hidden: yes
    can_filter: no
  }
  dimension: netflixid {
    type: number
    value_format_name: id
    sql: ${TABLE}."NETFLIXID" ;;
     hidden: yes
    primary_key: yes

  }

  #########################################################################

  dimension: download {
    type: string
    sql: ${TABLE}."DOWNLOAD" ;;
    hidden: yes
  }

  dimension: image {
    type: string
    sql: ${TABLE}."IMAGE" ;;
    hidden: yes
  }

  dimension: imdbid {
    type: string
    sql: ${TABLE}."IMDBID" ;;
    hidden: yes
  }

  dimension: largeimage {
    type: string
    sql: ${TABLE}."LARGEIMAGE" ;;
    hidden: yes
  }








  dimension: unogsdate {
    type: string
    sql: ${TABLE}."UNOGSDATE" ;;
    hidden: yes
  }

  dimension: videotype {
    type: string
    sql: ${TABLE}."VIDEOTYPE" ;;
    hidden: yes
    }


}

###################################
##SDR
##create an NDT that can allow us to select top x i.e. interact with a windows function :)
###################################

view: NDT_genretitlestreams {

    derived_table: {
      explore_source: didevexplore {
        column: genre { field: titlegenres.genre }
        column: netflixid { field: titlemaster.netflixid }
        column: title { field: contentmaster.title }
        column: streams { field: paneldata.streams }
        derived_column: pk {
          sql: ROW_NUMBER() OVER(ORDER BY NULL) ;;
        }
        derived_column: rowno {
          sql: ROW_NUMBER() OVER(PARTITION BY genre order by streams desc) ;;
        }
        derived_column: streams_totalsum {
          sql: sum(streams) over(partition by genre) ;;
        }
        bind_all_filters: yes
      }
    }

#######################################################################################
##Measures
#######################################################################################

  dimension: rowno {
    type: number
    view_label: "Genre Title League"
    label: "Title Ranking"
  }

  dimension: streams_totalsum {
    type: number
    view_label: "Genre Title League"
    label: "Total Streams per Genre per titles in selection"
    description: "Use this to sort the table by highest to lowest"
  }

  measure: streamsingenreleague {
    view_label: "Genre Title League"
    label: "Streams 000s"
    type: sum
    sql: ${streams} ;;
    value_format: "#,##0"
  }

#   parameter: numberingenreleague {
#     type: number
#     default_value: "5"
#     view_label: "Genre Title League"
#     label: "Top X Parameter"
#     description: "Enter the number of titles you would like to view in the league table per genre"
#   }

#   measure: streamsingenreleague {
#     view_label: "Genre Title League"
#     label: "Streams 000s"
#     description: "This returns the streams for the top x titles per genre (use in conjunction with Top X parameter)"
#     type: sum
#     sql: case when ${rowno} <=  {%parameter numberingenreleague %} then ${streams} else 0 end
#       ;;
#     value_format: "#,##0"
#   }
#
  #####################################################################################


    dimension: pk {
      primary_key: yes
      hidden: yes
    }

    dimension: genre {
      view_label: "Genre Title League"
      hidden: yes
    }

    dimension: netflixid {
      label: "Netflix ID"
      view_label: "Genre Title League"
      value_format: "0"
      type: number
      hidden: yes
    }
    dimension: title {
      view_label: "Genre Title League"
      label: "Title"
      hidden: yes
    }
    dimension: streams {
      view_label: "Genre Title League"
      label: "Streams 000s"
      value_format: "#,##0"
      type: number
       hidden: yes
    }
  }

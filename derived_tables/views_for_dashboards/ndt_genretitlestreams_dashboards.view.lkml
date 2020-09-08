# view: ndt_genretitlestreams_dashboards {
#
#   derived_table: {
#     explore_source: dashboardexplore {
#       column: genre { field: genresflattened.genre }
#       column: netflixid { field: titlemaster.netflixid }
#       column: title { field: contentmaster.title }
#       column: streams { field: paneldata.streams }
#       derived_column: pk {
#         sql: ROW_NUMBER() OVER(ORDER BY NULL) ;;
#       }
#       derived_column: rowno {
#         sql: ROW_NUMBER() OVER(PARTITION BY genre order by streams desc) ;;
#       }
#       derived_column: streams_totalsum {
#         sql: sum(streams) over(partition by genre) ;;
#       }
#       bind_all_filters: yes
#
#
#
#     }
#   }
#
# #######################################################################################
# ##Measures
# #######################################################################################
#
#   dimension: rowno {
#     type: number
#     view_label: "Title rank by genre"
#     label: "Title Ranking"
#   }
#
#   dimension: streams_totalsum {
#     type: number
#     view_label: "Title rank by genre"
#     label: "Total Streams per Genre per titles in selection"
#     description: "Use this to sort the table by highest to lowest"
#     can_filter: no
#   }
#
#   measure: streamsingenreleague {
#     view_label: "Title rank by genre"
#     label: "Streams 000s"
#     type: sum
#     sql: ${streams} ;;
#     value_format: "#,##0"
#     hidden: yes
#     ## DS 18/03/20 the usual streams measure can be used, gives same figures
#   }
#
# #   parameter: numberingenreleague {
# #     type: number
# #     default_value: "5"
# #     view_label: "Genre Title League"
# #     label: "Top X Parameter"
# #     description: "Enter the number of titles you would like to view in the league table per genre"
# #   }
#
# #   measure: streamsingenreleague {
# #     view_label: "Genre Title League"
# #     label: "Streams 000s"
# #     description: "This returns the streams for the top x titles per genre (use in conjunction with Top X parameter)"
# #     type: sum
# #     sql: case when ${rowno} <=  {%parameter numberingenreleague %} then ${streams} else 0 end
# #       ;;
# #     value_format: "#,##0"
# #   }
# #
#   #####################################################################################
#
#
#   dimension: pk {
#     primary_key: yes
#     hidden: yes
#   }
#
#   dimension: genre {
#     view_label: "Genre Title League"
#     hidden: yes
#   }
#
#   dimension: netflixid {
#     label: "Netflix ID"
#     view_label: "Genre Title League"
#     value_format: "0"
#     type: number
#     hidden: yes
#   }
#   dimension: title {
#     view_label: "Genre Title League"
#     label: "Title"
#     hidden: yes
#   }
#   dimension: streams {
#     view_label: "Genre Title League"
#     label: "Streams 000s"
#     value_format: "#,##0"
#     type: number
#     hidden: yes
#   }
# }
#
#
#
# ## All the possible filters to replace bind all filters and allow for explore extend! Important - if adding a dimention or filter that can be filtered and can potentially affect reach add it here
# #
# #
# #         bind_filters: {
# #           from_field: titlemaster.videotype
# #           to_field: titlemaster.videotype
# #         }
# #         bind_filters: {
# #           from_field: paneldata.date_raw
# #           to_field: paneldata.date_raw
# #         }
# #         bind_filters: {
# #           from_field: paneldata.respondantid
# #           to_field: paneldata.respondantid
# #         }
# #         bind_filters: {
# #           from_field: paneldata.diid
# #           to_field: paneldata.diid
# #         }
# #         bind_filters: {
# #           from_field: paneldata.country
# #           to_field: paneldata.country
# #         }
# #         bind_filters: {
# #           from_field: internationalweights.thousandsweight
# #           to_field: internationalweights.thousandsweight
# #         }
# #         bind_filters: {
# #           from_field: householddemo.haskids
# #           to_field: householddemo.haskids
# #         }
# #           bind_filters: {
# #             from_field: releasedate_dashboards.dayssincefirstviewed
# #             to_field: releasedate_dashboards.dayssincefirstviewed
# #           }
# #           bind_filters: {
# #             from_field: paneldata.Title_selection
# #             to_field: paneldata.Title_selection
# #           }
# #           bind_filters: {
# #             from_field: releasedate_dashboards.datefirstviewed
# #             to_field: releasedate_dashboards.datefirstviewed
# #            }
# #           bind_filters: {
# #             from_field: netflixoriginals.IsNetflixOriginalFullName
# #             to_field: netflixoriginals.IsNetflixOriginalFullName
# #           }
# #           bind_filters: {
# #             from_field: contentmaster.rating
# #             to_field: contentmaster.rating
# #           }
# #           bind_filters: {
# #             from_field: genresflattened.genre
# #             to_field: genresflattened.genre
# #           }
# #           bind_filters: {
# #             from_field: householddemo.accountholderagegroup
# #             to_field: householddemo.accountholderagegroup
# #           }
# #           bind_filters: {
# #             from_field: householddemo.accountholdergender
# #             to_field: householddemo.accountholdergender
# #           }
# #           bind_filters: {
# #             from_field: householddemo.rid
# #             to_field: householddemo.rid
# #           }
# #           bind_filters: {
# #             from_field: paneldata.netflixprofileid
# #             to_field: paneldata.netflixprofileid
# #           }
# #           bind_filters: {
# #             from_field: householddemo.has16_to34
# #             to_field: householddemo.has16_to34
# #           }
# #           bind_filters: {
# #             from_field: householddemo.has16_to44
# #             to_field: householddemo.has16_to44
# #           }
# #           bind_filters: {
# #             from_field: householddemo.kidsgroup
# #             to_field: householddemo.kidsgroup
# #           }
# #           bind_filters: {
# #             from_field: householddemo.sec
# #             to_field: householddemo.sec
# #           }
# #           bind_filters: {
# #             from_field: householddemo.secgroup
# #             to_field: householddemo.secgroup
# #           }
# #           bind_filters: {
# #             from_field: householddemo.householdsize
# #             to_field: householddemo.householdsize
# #           }
# #           bind_filters: {
# #             from_field: householddemo.hasprime
# #             to_field: householddemo.hasprime
# #           }
# #           bind_filters: {
# #             from_field: householddemo.housholdplatform
# #             to_field: householddemo.housholdplatform
# #           }

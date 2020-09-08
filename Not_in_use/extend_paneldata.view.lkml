include: "/*/*"
include: "/*/*/*"

view: extend_paneldata {

extends: [paneldata]


  measure: selected_episode {
    type:  sum
    sql:  case when ${episodes.episodenumber_IFNULL} = {% parameter episode_selection %} then ${finalweights.thousandsweight} else null end  ;;
    value_format: "#,##0"
    view_label: "Measures"
  }
  measure: other_episodes {
    type:  sum
    sql:  case when ${episodes.episodenumber_IFNULL} = {% parameter episode_selection %} then null else ${finalweights.thousandsweight} end  ;;
    value_format: "#,##0"
    view_label: "Measures"
  }
  parameter: episode_selection {
    type: number
    view_label: "Parameters"
  }





 }

view: navigation_bar {

  derived_table: {
    sql:
         SELECT 'https://i.imgur.com/r8URFuK.png' as Digitali,
                 'https://cdn4.iconfinder.com/data/icons/web-ui-color/128/Menu_green-512.png' as icon
--                 'https://media.istockphoto.com/vectors/signpost-line-icon-vector-id840551190' as icon
--                  SELECT 'http://icon-library.com/images/three-line-menu-icon/three-line-menu-icon-11.jpg' as icon --needs attribution
           ;;
  }

  dimension: icon {
    type: string
    sql: ${TABLE}.Digitali ;;
    html: <img src={{value}} height=100% width=100% /> ;;
    link: {
      label: "1. Amazon Overview"
      url:"/dashboards/200"
    }
    link: {
      label: "2. Content Overview"
      url:"/dashboards/201"
    }
    link: {
      label: "3. Series Explorer"
      url:"/dashboards/203"
    }
       link: {
      label: "4. Movie Explorer"
      url:"/dashboards/204"
    }
  #     link: {
#       label: "Episode Explorer"
#       url:"/dashboards/187"
#     }
#     link: {
#       label: "Title Comparison Dashboard"
#       url:"/dashboards/184"
#     }
#     link: {
#       label: "Genre Dashboard"
#       url:"/dashboards/188"   ##SDR 18/03/2020
#     }

    ##### DS 31/03 WHEN UPDATING DASHBOARD REFERENCES HERE DON'T FORGET TO ALSO UPDATE LINKS IN CONTENT NAME DYNAMIC AND TITLE (CONTENTMASTER)!!!!

    can_filter: no
  }

#   dimension: menu {
#     type: string
#     sql: ${TABLE}.icon ;;
#     html: <img src={{value}} height=60 /> ;;
#     label: " "
#
#     link: {
#       label: "Netflix Overview"
#       url:"/dashboards/113"
#     }
#     link: {
#       label: "Content Overview"
#       url:"/dashboards/112"
#     }
#     link: {
#       label: "Movie Explorer"
#       url:"/dashboards/115"
#     }
#     link: {
#       label: "Series Explorer"
#       url:"/dashboards/116"
#     }
#     link: {
#       label: "Episode Explorer"
#       url:"/dashboards/118"
#     }
#     link: {
#       label: "Title Comparison Dashboard"
#       url:"/dashboards/114"
#     }
#     link: {
#       label: "Genre Dashboard"
#       url:"/dashboards/105"
#      }

#     can_filter: no



#     html: {% assign words = {{value}} | split: ' ' %}
#     {% for word in words %}
#     {{ word | capitalize}}
#     {% endfor %};;
#     }

#   }

}

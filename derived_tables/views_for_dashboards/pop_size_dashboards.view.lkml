view: pop_size_dashboards {

  derived_table: {
    sql:
     select distinct
      a.country,
      a.panelyear,
      a.panelquarter,


--------Hidden parts in relation to householddemo columns is an attempt to allow for a breakdown by some demo parameters, didn't work - fanout, return to it later
      --{% if householddemo.sec._is_selected %} a.sec {% else %} 1 {% endif %},
      --{% if householddemo.kidsgroup._is_selected %} a.kidsgroup {% else %} 2 {% endif %},
      --{% if householddemo.secgroup._is_selected %} a.secgroup {% else %} 3 {% endif %},
      --{% if householddemo.housholdplatform._is_selected %} a.housholdplatform {% else %} 4 {% endif %},

      ------------------DYNAMIC PART
      sum(
      -- This part summarises weights for unique rids at a yearly, quartely or overall level, other potential breakdown parameters are not featured here because they provide unique value for each rid
      {% if paneldata.date_date._is_selected or paneldata.date_granularity._parameter_value == 'Date'
                     or paneldata.date_week._is_selected or paneldata.date_granularity._parameter_value == 'Week'
                     or paneldata.date_month._is_selected or paneldata.date_granularity._parameter_value == 'Month'
                     or paneldata.date_quarter._is_selected or paneldata.date_granularity._parameter_value == 'Quarter'
                    %} a.weighting

      {% elsif paneldata.date_year._is_selected or paneldata.date_granularity._parameter_value == 'Year' %} case when a.yearrowno = 1 then a.weighting else 0 end
      {% else %} case when a.wholeperiodrowno = 1 then a.weighting else 0 end {% endif %}
        )
      over (partition by
      --- This is the partitioning part for above, apart from standard country, period level other things like platform, sec etc can be added (will need to add them into select part and the join dynamically as well)
      {% if paneldata.countrynameformaps._is_selected %} a.country {% else %} 1 {% endif %}, --DS250320
      {% if paneldata.date_year._is_selected or paneldata.date_granularity._parameter_value == 'Year' %} a.panelyear {% else %} 1 {% endif %},
      {% if paneldata.date_date._is_selected or paneldata.date_granularity._parameter_value == 'Date'
                     or paneldata.date_week._is_selected or paneldata.date_granularity._parameter_value == 'Week'
                     or paneldata.date_month._is_selected or paneldata.date_granularity._parameter_value == 'Month'
                     or paneldata.date_quarter._is_selected or paneldata.date_granularity._parameter_value == 'Quarter'
                    %} a.panelyear, a.panelquarter {% else %} 1 {% endif %}

      --{% if householddemo.sec._is_selected %} a.sec {% else %} 1 {% endif %},
      --{% if householddemo.kidsgroup._is_selected %} a.kidsgroup {% else %} 1 {% endif %},
      --{% if householddemo.secgroup._is_selected %} a.secgroup {% else %} 1 {% endif %},
      --{% if householddemo.housholdplatform._is_selected %} a.housholdplatform {% else %} 1 {% endif %}

      ) dynamic
     -----------------END DYNAMIC PART

         from (
  --    select fw.*,    --SDR 01072020
      SELECT fw.RID,
             fw.WEIGHTING,
             fw.COUNTRY,
             fw.PANELYEAR,
             fw.PANELQUARTER,
       -- hd.sec,
        --hd.secgroup,
        --hd.HousholdPlatform,
        --hd.kidsgroup,
       row_number () over (partition by fw.country, fw.rid order by fw.panelyear desc, fw.panelquarter desc) wholeperiodrowno,
       row_number () over (partition by fw.country, fw.rid, fw.panelyear order by fw.panelquarter desc) yearrowno
      --at the quarter level weights table provides unique rids, but at more aggreate levels we need to cut off those that are repeated across quarters, hence row numbers

      from
      "CORE"."INTERNATIONALWEIGHTS" fw
      inner join "CORE"."PANELDATAINTERNATIONAL" pdq
      on fw.rid = pdq.RespondantID AND fw.PanelYear = YEAR(pdq.Date) AND fw.PanelQuarter = quarter(pdq.date) AND fw.COUNTRY = pdq.country
       inner JOIN "CORE"."HOUSEHOLDDEMOINTERNATIONAL" hd ON hd.RID = pdq.RespondantID AND hd.COUNTRY = pdq.COUNTRY
                  {% if ndt_dynamic_targeting_dashboards._in_query %} --if any field from dynamic targeting view is in query, limit population to only those households that are selected
      inner join ${ndt_dynamic_targeting_dashboards.SQL_TABLE_NAME} as ndt_dynamic_targeting_dashboards on hd.RID= ndt_dynamic_targeting_dashboards.rid
      and pdq.country=ndt_dynamic_targeting_dashboards.country
      and ndt_dynamic_targeting_dashboards.sample_threshold_flag = 1 and ndt_dynamic_targeting_dashboards.viewing_threshold_flag=1
       and {% condition ndt_dynamic_targeting_dashboards.HML_sample %} (case when ndt_dynamic_targeting_dashboards.percent_sample_running<=33.33 then 'Light' when ndt_dynamic_targeting_dashboards.percent_sample_running<=66.66 then 'Medium' when ndt_dynamic_targeting_dashboards.percent_sample_running<=100 then 'Heavy' else 'Fail' end) {% endcondition %}
      and {% condition ndt_dynamic_targeting_dashboards.HML_viewing %} (case when ndt_dynamic_targeting_dashboards.percent_viewing_running<=33.33 then 'Light' when ndt_dynamic_targeting_dashboards.percent_viewing_running<=66.66 then 'Medium' when ndt_dynamic_targeting_dashboards.percent_viewing_running<=100 then 'Heavy' else 'Fail' end) {% endcondition %}
      ------The part above adds the relationship between pop size and dynamic targeting, any custom filter that is imposed on columns created within the ndt (like HML, or custom threshold) have to have a separate line written for them
      {% endif %}
      WHERE
              {% condition paneldata.countrynameformaps %} CASE WHEN pdq.country = 'UK' THEN 'United Kingdom' ELSE  pdq.country END {% endcondition %}    --SDR 18/03/2020
              --depending on which explore is used
              and
              {% condition householddemo.housholdplatform %} hd.HousholdPlatform {% endcondition %}
              and
              {% condition householddemo.has16_to34 %} hd.Has16to34 = 1 {% endcondition %}
              and
              {% condition householddemo.has16_to44 %} hd.Has16to44 = 1 {% endcondition %}
              and
              {% condition householddemo.haskids %} hd.HasKids = 1 {% endcondition %}
              and
                  {% if paneldata.date_date._is_filtered %}
                   (date_from_parts(fw.panelyear, fw.panelquarter*3-2,1) >= trunc(ifnull({% date_start paneldata.date_date %},'{{ _user_attributes['netflix_v2_start'] }}'),'quarter')
                  and
                  date_from_parts(fw.panelyear, fw.panelquarter*3-2,1) <= trunc(dateadd(day,-1,ifnull({% date_end paneldata.date_date %},'{{ _user_attributes['netflix_v2_end'] }}')), 'quarter'))
                  --This filter allows to only select for calculation the quarters within which dates selected by the user fall
                  {% else %}
                  (date_from_parts(fw.panelyear, fw.panelquarter*3-2,1) >= trunc(to_date('{{ _user_attributes['netflix_v2_start'] }}'),'quarter')
                  and
                  date_from_parts(fw.panelyear, fw.panelquarter*3-2,1) <= trunc(to_date('{{ _user_attributes['netflix_v2_end'] }}'),'quarter'))
                  {% endif %}
              and
              {% condition householddemo.accountholderagegroup %} hd.accountholderagegroup {% endcondition %}
              and
              {% condition householddemo.accountholdergender %} hd.accountholdergender {% endcondition %}
              and
              {% condition householddemo.kidsgroup %} hd.kidsgroup {% endcondition %}
              and
              {% condition householddemo.sec %} hd.sec {% endcondition %}
              and
              {% condition householddemo.secgroup %} hd.secgroup {% endcondition %}
              and
              {% condition householddemo.householdsize %} hd.householdsize {% endcondition %}
              and
              pdq.country in ({{ _user_attributes['netflix_v2_country_access'] }})

      group by 1,2,3,4,5--,6,7,8,9
      ) a
      ;;

  }

#   dimension: pk {
#     hidden: yes
#     primary_key: yes
#   }

  dimension: country {
    hidden: yes
  }
  dimension: panelyear {
    hidden: yes
  }
  dimension: panelquarter {
    hidden: yes
  }

  dimension: sec {
    hidden: yes
  }

  dimension: kidsgroup {
    hidden: yes
  }

  dimension: secgroup {
    hidden: yes
  }

  dimension: housholdplatform {
    hidden: yes
  }

#   dimension: allpop {
#     hidden: yes
#     type: number
#     value_format_name: decimal_0
#   }
#   dimension: allyearpop {
#     hidden: yes
#     type: number
#     value_format_name: decimal_0
#   }
#   dimension: allquarterpop {
#     hidden: yes
#     type: number
#     value_format_name: decimal_0
#   }
#   dimension: countrypop {
#     hidden: yes
#     type: number
#     value_format_name: decimal_0
#   }
#   dimension: countryyearpop {
#     hidden: yes
#     type: number
#     value_format_name: decimal_0
#   }
#   dimension: countryquarterpop {
#     hidden: yes
#     type: number
#     value_format_name: decimal_0
#   }
  dimension: dynamic {
    hidden: yes
    type: number
    value_format_name: decimal_0
  }

  }



##First attempt where dynamic selection was coded into a measure within paneldata view, not at the DT level
#       -----------NON-DYNAMIC PART
#      -- row_number () over (order by null) pk,
#       -- our minimal level of population size is quarter - used whenever indication of a quarter or anything more granular is in query (broken down by or filtered by)
#       -- another levels allow for yearly population size and whole period population size
#       -- having or not having country in the split allows to acess total population of all our territories (might not need it, but ah well, let it be there)
#       sum(case when a.wholeperiodrowno = 1 then a.weighting else 0 end) over (partition by 1) allpop,
#       sum(case when a.yearrowno = 1 then a.weighting else 0 end) over (partition by a.panelyear) allyearpop,
#       sum(a.weighting) over (partition by a.panelyear, a.panelquarter) allquarterpop,
#       sum(case when a.wholeperiodrowno = 1 then a.weighting else 0 end) over (partition by a.country) countrypop,
#       sum(case when a.yearrowno = 1 then a.weighting else 0 end) over (partition by a.country, a.panelyear) countryyearpop,
#       sum(a.weighting) over (partition by a.country, a.panelyear, a.panelquarter) countryquarterpop,
#       ---------------------END NON-DYNAMIC PART

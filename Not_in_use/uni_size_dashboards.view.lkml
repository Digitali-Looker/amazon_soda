view: uni_size_dashboards {


    derived_table: {
      persist_for: "1 second"
      #indexes: ["FilteredPopulation"]

      sql:SELECT SUM(fw.WEIGHTING )  AS FilteredPopulation
        FROM (
              SELECT * FROM (

              SELECT pdq.COUNTRY , pdq.RespondantID,
                     pdq.Date, hd.DemoID,
                     ROW_NUMBER() OVER (PARTITION BY pdq.country, pdq.RespondantID ORDER BY pdq.Date DESC) AS RowNo
              FROM core.PANELDATAINTERNATIONAL pdq
              LEFT JOIN "CORE"."HOUSEHOLDDEMOINTERNATIONAL" hd ON hd.RID = pdq.RespondantID AND hd.COUNTRY = pdq.COUNTRY
              LEFT JOIN core.TitleMaster tm ON tm.TitleID = pdq.TitleID

              WHERE

              {% condition paneldata.countrynameformaps %} CASE WHEN pdq.country = 'UK' THEN 'United Kingdom' ELSE  pdq.country END {% endcondition %}    --SDR 18/03/2020
              --depending on which explore is used
              and
              {% condition householddemo.housholdplatform %} hd.HousholdPlatform {% endcondition %}
              and
              {% condition householddemo.has16_to34 %} Has16to34 = 1 {% endcondition %}
              and
              {% condition householddemo.has16_to44 %} Has16to44 = 1 {% endcondition %}
              and
              {% condition householddemo.haskids %} hd.HasKids = 1 {% endcondition %}
              and
              {% condition paneldata.date_date  %} pdq.date  {% endcondition  %}


          GROUP BY pdq.country, pdq.RespondantID,
                     pdq.Date, hd.DemoID
              ) a
              WHERE a.RowNo = 1
              ) b
              LEFT JOIN "CORE"."INTERNATIONALWEIGHTS" fw ON fw.rid = b.RespondantID AND fw.PanelYear = YEAR(b.Date) AND fw.PanelQuarter = DATE_PART(QUARTER, date) AND fw.COUNTRY = b.country
              ;;

      }

      dimension: filtered_population {
        primary_key: yes
        type: number
        sql: ${TABLE}.FilteredPopulation ;;
        view_label: "Temp"
        hidden: yes
      }

    }

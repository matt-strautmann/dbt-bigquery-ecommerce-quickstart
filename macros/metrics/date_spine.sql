{% macro date_spine(
    datepart,
    start_date,
    end_date
) %}

{%- set date_format = "YYYY-MM-DD" if datepart == "day" else "YYYY-MM" -%}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart=datepart,
        start_date=start_date,
        end_date=end_date
    ) }}
)

select
    date_day,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    extract(day from date_day) as day_of_month,
    extract(dayofweek from date_day) as day_of_week,
    extract(quarter from date_day) as quarter,
    format_date('{{ date_format }}', date_day) as period_id,
    -- Add fiscal year calculations if needed
    case
        when extract(month from date_day) >= 7
        then extract(year from date_day) + 1
        else extract(year from date_day)
    end as fiscal_year
from date_spine

{% endmacro %}

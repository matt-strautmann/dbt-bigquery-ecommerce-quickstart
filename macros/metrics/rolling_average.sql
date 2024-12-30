{% macro rolling_average(
    measure,
    partition_by,
    order_by,
    window_size=7
) %}

avg({{ measure }}) over (
    partition by {{ partition_by }}
    order by {{ order_by }}
    rows between {{ window_size - 1 }} preceding and current row
)

{% endmacro %}

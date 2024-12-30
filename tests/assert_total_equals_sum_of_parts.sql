{% test total_equals_sum_of_parts(model, total_column, part_columns) %}

with validation as (
    select
        {{ total_column }} as total_amount,
        {% for column in part_columns %}
            {{ column }}{% if not loop.last %} + {% endif %}
        {% endfor %} as sum_of_parts
    from {{ model }}
)

select *
from validation
where abs(total_amount - sum_of_parts) > 0.01

{% endtest %}

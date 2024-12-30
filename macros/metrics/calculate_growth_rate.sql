{% macro calculate_growth_rate(
    current_value,
    previous_value
) %}
    safe_divide(
        {{ current_value }} - {{ previous_value }},
        {{ previous_value }}
    )
{% endmacro %}

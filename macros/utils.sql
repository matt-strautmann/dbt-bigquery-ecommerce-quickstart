{% macro generate_surrogate_key(field_list) %}
    {{ dbt_utils.surrogate_key(field_list) }}
{% endmacro %}

{% macro hash_value(field) %}
    SHA256(CAST({{ field }} AS STRING))
{% endmacro %}

{% macro current_timestamp() %}
    CURRENT_TIMESTAMP()
{% endmacro %}

{% macro date_trunc(datepart, date) %}
    DATE_TRUNC({{ date }}, {{ datepart }})
{% endmacro %}

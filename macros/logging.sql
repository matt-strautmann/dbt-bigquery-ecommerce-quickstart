{% macro log_model_timing() %}
    {% set query %}
        INSERT INTO {{ target.schema }}.dbt_model_timing (
            model_name,
            materialization,
            schema_name,
            execution_time_seconds,
            rows_affected,
            created_at
        )
        SELECT 
            '{{ this.name }}' as model_name,
            '{{ this.config.materialized }}' as materialization,
            '{{ this.schema }}' as schema_name,
            {{ status.execution_time }} as execution_time_seconds,
            {{ status.rows_affected }} as rows_affected,
            CURRENT_TIMESTAMP() as created_at
    {% endset %}

    {% do run_query(query) %}
{% endmacro %}

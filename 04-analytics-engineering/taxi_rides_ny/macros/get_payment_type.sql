{% macro get_payment_type(payment_type) %}
CASE
    WHEN {{ payment_type }} = 1 THEN 'Credit Card'
    WHEN {{ payment_type }} = 2 THEN 'Cash'
    WHEN {{ payment_type }} = 3 THEN 'No Charge'
    WHEN {{ payment_type }} = 4 THEN 'Dispute'
    WHEN {{ payment_type }} = 5 THEN 'Unknown'
END
{% endmacro %}
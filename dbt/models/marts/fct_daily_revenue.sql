-- Fact: completed revenue by day and category (grain = day x category).
select
    order_date,
    category,
    count(*)                       as order_count,
    round(sum(amount), 2)          as revenue,
    round(avg(amount), 2)          as avg_order_value
from {{ ref('stg_orders') }}
where status = 'completed'
group by order_date, category

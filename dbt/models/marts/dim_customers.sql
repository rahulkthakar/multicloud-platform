-- Dimension: customers enriched with lifetime completed spend.
with spend as (
    select customer_id, round(sum(amount), 2) as lifetime_spend
    from {{ ref('stg_orders') }}
    where status = 'completed'
    group by customer_id
)
select
    c.customer_id,
    c.customer_name,
    c.province,
    c.signup_date,
    coalesce(s.lifetime_spend, 0)  as lifetime_spend
from {{ ref('stg_customers') }} c
left join spend s using (customer_id)

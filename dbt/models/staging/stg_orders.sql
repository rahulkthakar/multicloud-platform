-- Staging: type, rename, and filter raw orders. One source concern per model.
select
    cast(order_id as integer)      as order_id,
    customer_id,
    cast(order_date as date)       as order_date,
    lower(category)                as category,
    cast(amount as double)         as amount,
    lower(status)                  as status
from {{ ref('raw_orders') }}

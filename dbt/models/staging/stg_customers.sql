select
    customer_id,
    customer_name,
    upper(province)                as province,
    cast(signup_date as date)      as signup_date
from {{ ref('raw_customers') }}

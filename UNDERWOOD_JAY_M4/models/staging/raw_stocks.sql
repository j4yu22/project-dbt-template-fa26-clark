with cleaned as (
    select
        nullif(upper(trim(symbol::varchar)), '') as symbol,
        datetime::timestamp_ntz as datetime,
        datetime::date as trade_date,
        open::float as open,
        high::float as high,
        low::float as low,
        close::float as close,
        volume::number(38, 0) as volume
    from {{ source('snowbearair', 'UNDERWOOD_JAY_M3') }}
)

select
    symbol,
    datetime,
    trade_date,
    open,
    high,
    low,
    close,
    volume
from cleaned
qualify row_number() over (
    partition by symbol, trade_date
    order by datetime desc nulls last, hash(open, high, low, close, volume)
) = 1

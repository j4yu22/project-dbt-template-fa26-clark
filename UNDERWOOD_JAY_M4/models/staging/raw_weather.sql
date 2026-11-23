with cleaned as (
    select
        date::date as date,
        nullif(upper(trim(city::varchar)), '') as city,
        max_temp::float as max_temp,
        min_temp::float as min_temp,
        coalesce(precip::float, 0.0) as precip,
        coalesce(max_wind::float, 0.0) as max_wind,
        coalesce(max_wind_mph::float, round(max_wind::float / 1.609344, 2), 0.0) as max_wind_mph,
        coalesce(precip_inches::float, round(precip::float / 25.4, 2), 0.0) as precip_inches,
        temp_midpoint_f::float as temp_midpoint_f
    from {{ source('snowbearair', 'UNDERWOOD_J_M1') }}
)

select
    date,
    city,
    max_temp,
    min_temp,
    precip,
    max_wind,
    max_wind_mph,
    precip_inches,
    temp_midpoint_f
from cleaned
qualify row_number() over (
    partition by city, date
    -- RAW has no load timestamp, so use a repeatable tie-breaker.
    order by hash(max_temp, min_temp, precip, max_wind,
                  max_wind_mph, precip_inches, temp_midpoint_f)
) = 1

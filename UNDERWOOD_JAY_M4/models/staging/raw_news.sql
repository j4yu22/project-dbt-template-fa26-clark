with cleaned as (
    select
        id::varchar as id,
        coalesce(published_at::timestamp_ntz,
                 to_timestamp_ntz(datetime::number(38, 0), 0)) as datetime,
        nullif(trim(headline::varchar), '') as headline,
        coalesce(nullif(lower(trim(category::varchar)), ''), 'unknown') as category,
        coalesce(nullif(trim(source::varchar), ''), 'Unknown') as source,
        nullif(upper(trim(related::varchar)), '') as related,
        coalesce(trim(summary::varchar), '') as summary,
        nullif(trim(url::varchar), '') as url,
        nullif(trim(image::varchar), '') as image,
        source_file::varchar as source_file,
        source_date::date as source_date,
        loaded_at::timestamp_ntz as loaded_at
    from {{ source('snowbearair', 'UNDERWOOD_JAY_M2') }}
)

select
    id,
    datetime,
    datetime as published_at,
    headline,
    category,
    source,
    related,
    summary,
    url,
    image,
    source_file,
    source_date,
    loaded_at
from cleaned
qualify row_number() over (
    partition by id
    order by loaded_at desc nulls last, datetime desc nulls last,
             source_file desc nulls last, source_date desc nulls last,
             hash(headline, category, source, related, summary, url, image)
) = 1

with checks as (
    select 'RAW_NEWS_UNDERWOODJ' as view_name, count(*) as row_count,
           count(*) - count(distinct id) as duplicate_keys,
           count_if(id is null) as null_keys
    from PROJECT_DB.STAGING.RAW_NEWS_UNDERWOODJ
    union all
    select 'RAW_STOCKS_UNDERWOODJ', count(*),
           count(*) - count(distinct symbol || '|' || trade_date),
           count_if(symbol is null or trade_date is null)
    from PROJECT_DB.STAGING.RAW_STOCKS_UNDERWOODJ
    union all
    select 'RAW_WEATHER_UNDERWOODJ', count(*),
           count(*) - count(distinct city || '|' || date),
           count_if(city is null or date is null)
    from PROJECT_DB.STAGING.RAW_WEATHER_UNDERWOODJ
)
select t.table_catalog as database_name, t.table_schema as schema_name,
       c.view_name, t.table_type, c.row_count, c.duplicate_keys, c.null_keys
from checks c
join PROJECT_DB.INFORMATION_SCHEMA.TABLES t
    on t.table_name = c.view_name
    and t.table_schema = 'STAGING'
order by c.view_name;

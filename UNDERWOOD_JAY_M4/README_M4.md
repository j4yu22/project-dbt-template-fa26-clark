# Milestone 4 — Jay Underwood

The three staging models clean my existing Airflow data into views in `PROJECT_DB.STAGING`. The original template and the later warehouse/mart assignments are unchanged. Canvas asks for the folder name `LAST_FIRST_M4`, so this project is in `UNDERWOOD_JAY_M4`.

| Model | RAW source | Staging view | Key |
| --- | --- | --- | --- |
| `raw_news` | `UNDERWOOD_JAY_M2` | `RAW_NEWS_UNDERWOODJ` | Article ID |
| `raw_stocks` | `UNDERWOOD_JAY_M3` | `RAW_STOCKS_UNDERWOODJ` | Symbol and trading date |
| `raw_weather` | `UNDERWOOD_J_M1` | `RAW_WEATHER_UNDERWOODJ` | City and date |

News uses the newest load for each article, trims text, standardizes tickers, and converts publication times to timestamps. Stocks use typed prices and volume, uppercase tickers, and a trading date. Weather uses typed measurements and uppercase cities, keeps Fahrenheit temperatures, and follows the assignment's zero default for missing precipitation and wind. All three use `QUALIFY ROW_NUMBER()` to remove duplicate keys after cleaning. Unknown temperatures and prices are not replaced with invented values.

## Run in Snowflake

In workspace `UNDERWOOD_JAY_M4`, select branch `milestone-4-review`, project `UNDERWOOD_JAY_M4`, and profile `dev`. Use these commands in order:

```text
dbt deps
dbt compile
dbt run --select staging
dbt test
dbt test --select raw_news raw_stocks raw_weather
```

`deps` reports no packages, as expected. The staging selection builds only this milestone's three views. Later warehouse/mart files remain template exercises. `profiles.yml` uses the signed-in Snowflake session; no credentials are stored in Git. The workspace reads the public fork; commit and push later edits through local Git.

## Test fixes

The first full test run found repeated RAW news IDs and one zero-volume stock record. The news loader appends a new load rather than replacing older loads, so its source key is `SOURCE_DATE + SOURCE_FILE + ID + LOADED_AT`. Source tests check that key and each component; the staging test still requires unique article IDs. Volume now uses a nonnegative test, while stock prices still must be positive. These changes match the actual source data and ingestion code; no RAW records were deleted or altered.

News keeps the selected article version's `RELATED` ticker. A future article-to-ticker bridge would be needed to preserve every ticker association in downstream reporting. Weather has no load timestamp, so its tie-breaker is repeatable rather than claiming to identify the latest load. Background Airflow loads can change row counts while these views are queried.

The screenshots and brief Canvas response are in the desktop `Milestone 4 Deliverables` folder. Review them and the code before opening the class submission PR or submitting anything in Canvas.

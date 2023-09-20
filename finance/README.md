# prql-exec/finance

## Installation

### Steampipe

The Finance plugin requires Steampipe. 
See the Steampipe installation instructions in
[steampipe/README.md](../steampipe/README.md).

### Finance plugin

Install the `finance` plugin:
```sh
steampipe plugin install finance
```

## Documentation

Details can be found on [steampipe.io](https://hub.steampipe.io/plugins/turbot/finance).

In particular you can see the [table definitions](https://hub.steampipe.io/plugins/turbot/finance/tables).

## Examples

### OHLC for Apple (AAPL) for the last 10 days

```sh
❯ prql <<eof
import finance
from finance.quote_daily
filter symbol=='AAPL'
take 10
eof
+---------------------------+--------+--------------------+--------------------+--------------------+--------------------+--------------------+-----------+
| timestamp                 | symbol | open               | high               | low                | close              | adjusted_close     | volume    |
+---------------------------+--------+--------------------+--------------------+--------------------+--------------------+--------------------+-----------+
| 2023-09-20T22:00:02+02:00 | AAPL   | 179.25999450683594 | 179.67999267578125 | 175.39999389648438 | 175.49000549316406 | 175.49000549316406 | 55483282  |
| 2023-09-19T15:30:00+02:00 | AAPL   | 177.52000427246094 | 179.6300048828125  | 177.1300048828125  | 179.07000732421875 | 179.07000732421875 | 51826900  |
| 2023-09-18T15:30:00+02:00 | AAPL   | 176.47999572753906 | 179.3800048828125  | 176.1699981689453  | 177.97000122070312 | 177.97000122070312 | 67257600  |
| 2023-09-15T15:30:00+02:00 | AAPL   | 176.47999572753906 | 176.5              | 173.82000732421875 | 175.00999450683594 | 175.00999450683594 | 109205100 |
| 2023-09-14T15:30:00+02:00 | AAPL   | 174                | 176.10000610351562 | 173.5800018310547  | 175.74000549316406 | 175.74000549316406 | 60895800  |
| 2023-09-13T15:30:00+02:00 | AAPL   | 176.50999450683594 | 177.3000030517578  | 173.97999572753906 | 174.2100067138672  | 174.2100067138672  | 84267900  |
| 2023-09-12T15:30:00+02:00 | AAPL   | 179.49000549316406 | 180.1300048828125  | 174.82000732421875 | 176.3000030517578  | 176.3000030517578  | 90370200  |
| 2023-09-11T15:30:00+02:00 | AAPL   | 180.07000732421875 | 180.3000030517578  | 177.33999633789062 | 179.36000061035156 | 179.36000061035156 | 58953100  |
| 2023-09-08T15:30:00+02:00 | AAPL   | 178.35000610351562 | 180.24000549316406 | 177.7899932861328  | 178.17999267578125 | 178.17999267578125 | 65551300  |
| 2023-09-07T15:30:00+02:00 | AAPL   | 175.17999267578125 | 178.2100067138672  | 173.5399932861328  | 177.55999755859375 | 177.55999755859375 | 112488800 |
+---------------------------+--------+--------------------+--------------------+--------------------+--------------------+--------------------+-----------+
```

### Latest quotes for Amazon (AMZN)

```sh
❯ prql <<eof - --output json
import finance
from finance.quote
filter symbol=='AMZN'
eof
[
 {
  "_ctx": {
   "connection_name": "finance"
  },
  "ask": 135.29,
  "ask_size": 8,
  "average_daily_volume_10_day": 55968790,
  "average_daily_volume_3_month": 53631947,
  "bid": 135.06,
  "bid_size": 8,
  "currency_id": "USD",
  "exchange_id": "NMS",
  "exchange_timezone_name": "America/New_York",
  "exchange_timezone_short_name": "EDT",
  "fifty_day_average": 135.3154,
  "fifty_day_average_change": -0.025405884,
  "fifty_day_average_change_percent": -0.00018775309,
  "fifty_two_week_high": 145.86,
  "fifty_two_week_high_change": -10.570007,
  "fifty_two_week_high_change_percent": -0.0724668,
  "fifty_two_week_low": 81.43,
  "fifty_two_week_low_change": 53.859993,
  "fifty_two_week_low_change_percent": 0.6614269,
  "full_exchange_name": "NasdaqGS",
  "gmt_offset_milliseconds": -14400000,
  "is_tradeable": false,
  "market_id": "us_market",
  "market_state": "POST",
  "post_market_change": -0.1499939,
  "post_market_change_percent": -0.11086843,
  "post_market_price": 135.14,
  "post_market_time": "2023-09-20T22:42:59+02:00",
  "pre_market_change": 0,
  "pre_market_change_percent": 0,
  "pre_market_price": 0,
  "pre_market_time": null,
  "quote_delay": 0,
  "quote_source": "Nasdaq Real Time Price",
  "quote_type": "EQUITY",
  "regular_market_change": -2.3400116,
  "regular_market_change_percent": -1.7002192,
  "regular_market_day_high": 139.37,
  "regular_market_day_low": 135.2,
  "regular_market_open": 138.55,
  "regular_market_previous_close": 137.63,
  "regular_market_price": 135.29,
  "regular_market_time": "2023-09-20T22:00:01+02:00",
  "regular_market_volume": 42127744,
  "short_name": "Amazon.com, Inc.",
  "source_interval": 15,
  "symbol": "AMZN",
  "two_hundred_day_average": 111.64295,
  "two_hundred_day_average_change": 23.647041,
  "two_hundred_day_average_change_percent": 0.21180953
 }
]
```

### Filer details from the US Securities and Exrchange Commission (SEC) Edgar database

```sh
❯ prql <<eof
import finance
from finance.us_sec_filer
filter symbol=='GOOG'
take 10
eof
+--------+------------+---------------+------+------------------------------------------------------+-------------------------------+
| symbol | cik        | name          | sic  | sic_description                                      | _ctx                          |
+--------+------------+---------------+------+------------------------------------------------------+-------------------------------+
| GOOG   | 0001652044 | Alphabet Inc. | 7370 | SERVICES-COMPUTER PROGRAMMING, DATA PROCESSING, ETC. | {"connection_name":"finance"} |
+--------+------------+---------------+------+------------------------------------------------------+-------------------------------+
```

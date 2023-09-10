# prql-exec/duckdb

## Getting started

### Install DuckDB

See https://duckdb.org/docs/installation/

### Install the `httpfs` extension

```sh
duckdb -c 'INSTALL httpfs;'
```

## Example usage

### Download some Google Stock data to work with

```sh
mkdir _data
wget https://vincentarelbundock.github.io/Rdatasets/csv/causaldata/google_stock.csv -o _data/
```

### Query the Google stock data

```sh
❯ prql-exec 'import duckdb\nfrom `_data/google_stock.csv`'
```


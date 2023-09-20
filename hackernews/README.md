# prql-exec/hackernews

## Installation

### Steampipe

The Hackernews plugin requires Steampipe. 
See the Steampipe installation instructions in
[steampipe/README.md](../steampipe/README.md).

### Hackernews plugin

Install the `hackernews` plugin:
```sh
steampipe plugin install hackernews
```

## Documentation

Details can be found on [steampipe.io](https://hub.steampipe.io/plugins/turbot/hackernews).

In particular you can see the [table definitions](https://hub.steampipe.io/plugins/turbot/hackernews/tables).

## Examples

Current top stories

```sh
prql-exec <<eof
import hackernews as hn
from hn.top
take 10
eof
```

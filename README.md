# prql-exec

`prql-exec` is an experimental shell script to make
system tools that accept SQL input easily accessible
as PRQL libraries.

## Getting started

### Install prql-exec

```sh
git clone https://github.com/snth/prql-exec.git
cd prql-exec
ln -sf "$(pwd)/prql-exec" ~/.local/bin/prql-exec
export PRQL_LIB_PATH=".:$(pwd)"
```

Since without an `import` statement, `prql-exec` will just
output the SQL produced, I usually just alias it to `prql`
with:

```sh
alias prql=prql-exec
```

## Example usage

The libraries included by default are:

- [duckdb](duckdb/README.md)
- [git (mergestat)](git/README.md)
- [os (osquery)](os/README.md)
- [postgres](postgres/README.md)
- [sqlite](sqlite/README.md)

## Adding libraries

Libraries can be added by creating a <library>/ directory
with a <Library.prql> file in it. This can then be used
in PRQL queries with the `import <library>` command.

Moreover, if there is a `.env` file in the <library>/
directory, it will be "sourced" and if there is a
`PRQL_EXEC_COMMAND` environment variable defined in that
file, then the generated SQL will be piped to that command.

The `PRQL_EXEC_COMMAND` needs to accept SQL being piped to
it on stdin. For executables that expect SQL as a different
argument, this can usually easily be achieved by using
`"$(cat)"` as a parameter, see for example:

```sh
PRQL_EXEC_COMMAND='osqueryi "$(cat)"'
```

## Adding private libraries

This can be used to set up convenient aliases to internal
databases. For example by creating a file `_prod/.env`

```sh
# _prod/.env
PGHOST=postgres
PGPORT=5432
PGDATABASE=postgres
PGUSER=postgres
PGPASSWORD=postgres
PRQL_COMPILE_OPTIONS="--target=sql.postgres --hide-signature-comment"
PRQL_EXEC_COMMAND=psql
```

you can easily connect to a Postres database with a command like:
```sh
prql-exec "import _prod\nfrom information_schema.sql_features"
```

In order to prevent you from accidentally commiting any access
credentials stored in such a file to git, all libraries beginning
with a leading `_` are ignored in the .gitignore.

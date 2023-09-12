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
in PRQL queries with the `import <library>` statement.

Moreover, if there is a `.env` file in the <library>/
directory, it will be "sourced" and if there is a
`PRQL_EXEC_COMMAND` environment variable defined in that
file, then that command will be executed via `eval`.
The generated SQL will be passed to it via a `"$sql"`
argument. Options that can be overridden by the user
at runtime should be defined in `PRQL_EXEC_OPTIONS`.
Options that should never be overriden can simple
be included in the COMMAND.

The general form of the command definition 
should be something like:

Please note that the quotes around `$sql` and the lack
of quotes around `$PRQL_EXEC_OPTIONS` are important!

For executables that expect to receive SQL via STDIN,
this can usually easily be achieved by using a command
definition as follows:

```sh
PRQL_EXEC_COMMAND='echo "$sql" | <COMMAND> $PRQL_EXEC_OPTIONS'
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

# prql-exec

`prql-exec` is an experimental shell script to make
system tools that accept SQL input easily accessible
as PRQL libraries.

## Getting started

### Install prql-exec

```sh
git clone https://github.com/snth/prql-exec.git
cd prql-exec
ln -s prql-exec ~/.local/bin/prql-exec
export PRQL_LIB_PATH=".:$(pwd)"
```

## Example usage

See the READMEs of some of the default libraries.

- [git/README.md]()
- [os/README.md]()

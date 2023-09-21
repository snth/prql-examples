# prql-exec/git

## Getting started

### Install mergestat

```sh
brew tap mergestat/mergestat
brew install mergestat
```

## Example usage

### Get last 5 commits

```sh
prql-exec "import git\nfrom git.commits|sort {-author_when}|take 5"
```

### Top 10 authors

```sh
prql-exec <<EOF
import git
from git.top_authors
take 10
EOF
```

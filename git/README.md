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

### Top 10 committers

```sh
prql-exec <<EOF
import git

from git.commits
group {author_name} (
  aggregate {num_commits = count this}
)
sort {-num_commits}
take 10
EOF
```

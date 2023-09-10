# prql-exec

## Getting started

### Install prql-exec

```sh
git clone https://github.com/snth/prql-examples.git
cd prql-examples
source prql-cli.sh
export PRQL_LIB_PATH=".:$(pwd)"
```

### Install mergestat

```sh
brew tap mergestat/mergestat
brew install mergestat
```

### Install osquery

See https://osquery.io/downloads/official/5.9.1:

Mac
```sh
brew install --cask osquery
```

Linux
```sh
sudo mkdir -p /etc/apt/keyrings
curl -L https://pkg.osquery.io/deb/pubkey.gpg | sudo tee /etc/apt/keyrings/osquery.asc
sudo add-apt-repository 'deb [arch=amd64 signed-by=/etc/apt/keyrings/osquery.asc] https://pkg.osquery.io/deb deb main'
sudo apt install osquery
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

### First 5 system users

```sh
prql-exec "import os\n\nfrom users | take 5"
```

### 5 largest processes

```sh
prql-exec "import os\n\nfrom processes|sort {-total_size}|select {pid,name,path,cmdline,total_size}|take 5""
```

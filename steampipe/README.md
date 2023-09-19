# prql-exec/steampipe

## Installation

This follows the instructions from: https://steampipe.io/downloads

### Linux

Install the `steampipe` CLI binary:
```sh
sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/turbot/steampipe/main/install.sh)"
```

### Docker

```sh
# Download the Docker image
docker pull ghcr.io/turbot/steampipe:latest

# Create a directory for the config files
mkdir -p $HOME/.steampipe/{config,plugins}

# Aalias the command
alias steampipe="docker run \
  -it \
  --rm \
  --name steampipe \
  --mount type=bind,source=$HOME/.steampipe/config,target=/home/steampipe/.steampipe/config  \
  --mount type=bind,source=$HOME/.steampipe/plugins,target=/home/steampipe/.steampipe/plugins   \
  --mount type=bind,source=$HOME/.steampipe/internal,target=/home/steampipe/.steampipe/internal \
  --mount type=bind,source=$HOME/.steampipe/logs,target=/home/steampipe/.steampipe/logs   \
  --mount type=bind,source=$HOME/.steampipe/data,target=/home/steampipe/.steampipe/db/14.2.0/data \
  ghcr.io/turbot/steampipe"
```

### Check your installation

Check the version:
```sh
steampipe -v
```

Install your first plugin:
```sh
steampipe plugin install steampipe
```

Run your first query:
```sh
steampipe query "select name from steampipe_registry_plugin;"
```

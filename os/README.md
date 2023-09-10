# prql-exec/os

## Getting started

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

### First 5 system users

```sh
prql-exec "import os\n\nfrom users | take 5"
```

### 5 largest processes

```sh
prql-exec "import os\n\nfrom processes|sort {-total_size}|select {pid,name,path,cmdline,total_size}|take 5""
```

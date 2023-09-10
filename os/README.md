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

Look up the available table in the osquery schema: https://www.osquery.io/schema/

### Query your current `os_version`

```sh
❯ prql-exec "import os\nfrom os_version"
+--------+---------------------------+-------+-------+-------+-------+----------+---------------+----------+--------+
| name   | version                   | major | minor | patch | build | platform | platform_like | codename | arch   |
+--------+---------------------------+-------+-------+-------+-------+----------+---------------+----------+--------+
| Ubuntu | 20.04.6 LTS (Focal Fossa) | 20    | 4     | 0     |       | ubuntu   | debian        | focal    | x86_64 |
+--------+---------------------------+-------+-------+-------+-------+----------+---------------+----------+--------+
```

### Query your `system_version`

```sh
❯ prql-exec "import os\nfrom system_info|select {hostname,cpu_type,cpu_brand,computer_name,cpu_physical_cores,cpu_logical_cores,cpu_sockets,physical_memory}"
+----------------------+----------+------------------------------------------+---------------+--------------------+-------------------+-------------+-----------------+
| hostname             | cpu_type | cpu_brand                                | computer_name | cpu_physical_cores | cpu_logical_cores | cpu_sockets | physical_memory |
+----------------------+----------+------------------------------------------+---------------+--------------------+-------------------+-------------+-----------------+
| *********.****.local | x86_64   | Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz | **********    | 4                  | 8                 | 1           | 8248033280      |
+----------------------+----------+------------------------------------------+---------------+--------------------+-------------------+-------------+-----------------+
```

### First 5 system users

```sh
❯ echo "import os\n\nfrom users|take 5" | prql-exec
+-----+-------+------------+------------+----------+-------------+-----------+-------------------+------+
| uid | gid   | uid_signed | gid_signed | username | description | directory | shell             | uuid |
+-----+-------+------------+------------+----------+-------------+-----------+-------------------+------+
| 0   | 0     | 0          | 0          | root     | root        | /root     | /bin/bash         |      |
| 1   | 1     | 1          | 1          | daemon   | daemon      | /usr/sbin | /usr/sbin/nologin |      |
| 2   | 2     | 2          | 2          | bin      | bin         | /bin      | /usr/sbin/nologin |      |
| 3   | 3     | 3          | 3          | sys      | sys         | /dev      | /usr/sbin/nologin |      |
| 4   | 65534 | 4          | 65534      | sync     | sync        | /bin      | /bin/sync         |      |
+-----+-------+------------+------------+----------+-------------+-----------+-------------------+------+
```

### Query your running `proccesses`

```sh
❯ prql-exec "import os\nfrom processes|sort {-system_time}|select {pid,name,path,cmdline,start_time,parent,threads,state,uid,gid,user_time,system_time}|take 5"
+--------+-----------------+----------------------+------------------------------------------------------------------------+------------+--------+---------+-------+------+------+-----------+-------------+
| pid    | name            | path                 | cmdline                                                                | start_time | parent | threads | state | uid  | gid  | user_time | system_time |
+--------+-----------------+----------------------+------------------------------------------------------------------------+------------+--------+---------+-------+------+------+-----------+-------------+
| 3672   | containerd      |                      | /usr/bin/containerd                                                    | 1693901988 | 1      | 14      | S     | 0    | 0    | 845630    | 906220      |
| 705    | Relay(706)      |                      | /init                                                                  | 1693901905 | 704    | 1       | S     | 0    | 0    | 1870      | 12840       |
| 79     | systemd-udevd   |                      | /lib/systemd/systemd-udevd                                             | 1693901900 | 1      | 1       | S     | 0    | 0    | 1970      | 8770        |
| 1      | systemd         |                      | /sbin/init                                                             | 1693901899 | 0      | 1       | S     | 0    | 0    | 6960      | 7730        |
| 287    | accounts-daemon |                      | /usr/lib/accountsservice/accounts-daemon                               | 1693901901 | 1      | 3       | S     | 0    | 0    | 4730      | 5840        |
+--------+-----------------+----------------------+------------------------------------------------------------------------+------------+--------+---------+-------+------+------+-----------+-------------+
```

## rsync/ssh 命令在Linux的应用

#### (1) 编写脚本`/usr/local/bin/xsync`(内容如下) 并赋予该脚本可执行权限

```bash
#!/usr/bin/env bash

set -e

if [ $# -lt 2 ]
then
  echo "invalid parameters"
  exit 1
fi

group=$1
groupfile="/etc/xgrp/$1"

if [ ! -f $groupfile ]
then
    echo "no such group: $group. create file '/etc/xgrp/<group>' please"
    exit 1
fi

hosts=$(cat $groupfile | tr '\r\n' ' ')

if [ "x" == "x$hosts" ]
then
    echo "group not set"
    exit 1
fi

shift

for host in $hosts
do
  echo "--------------------------  $host  --------------------------"
  for file in $@
  do
    if [ -e $file ]
    then
      pdir=$(cd -P $(dirname $file); pwd)
      fname=$(basename $file)
      ssh $host "mkdir -p $pdir"
      rsync -av --delete-excluded $pdir/$fname $host:$pdir
    else
      echo "file/dir does not exists: $file"
    fi
  done
  echo ""
done

exit 0
```

#### (2) 创建`/usr/local/bin/xcmd`(内容如下) 并赋予该脚本可执行权限

```bash
#!/usr/bin/env bash

set -e

if [ $# -lt 2 ]
then
  echo "invalid parameters"
  exit 1
fi

group=$1
groupfile="/etc/xgrp/$1"

if [ ! -f $groupfile ]
then
    echo "no such group: $group. create file '/etc/xgrp/<group>' please"
    exit 1
fi

hosts=$(cat $groupfile | tr '\r\n' ' ')

if [ "x" == "x$hosts" ]
then
    echo "group not set"
    exit 1
fi

shift

for host in $hosts
do
  echo "--------------------------  $host  --------------------------"
  ssh $host $@
  echo ""
done

exit 0
```

#### (3) 创建`/etc/xgrp`目录以保存组信息。(如: `/etc/xsync/k8s`)

```text
root@k8s-master1
root@k8s-master2
root@k8s-master3
root@k8s-slave1
root@k8s-slave2
root@k8s-slave3
root@k8s-slave4
root@k8s-slave5
```

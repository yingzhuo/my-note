## rsync命令在Linux的应用

```bash
#!/bin/bash -e

if [ $# -lt 1 ]
then
  exit 0;
fi

for host in lion bear
do
  echo ====================  $host  ====================
  for file in $@
  do
    if [ -e $file ]
    then
      pdir=$(cd -P $(dirname $file); pwd)
      fname=$(basename $file)
      ssh $host "mkdir -p $pdir"
      rsync -av $pdir/$fname $host:$pdir
    else
      echo $file does not exists!
    fi
  done
done
```

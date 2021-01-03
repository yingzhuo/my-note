## 为pip配置阿里源

```bash
mkdir -p $HOME/.pip
touch $HOME/.pip/pip.conf
```

`$HOME/.pip/pip.conf`文件编辑为如下:

```ini
[global]
timeout = 6000
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirriros.aliyun.com
```

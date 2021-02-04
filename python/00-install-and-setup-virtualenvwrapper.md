## 安装与设定virtualenvwrapper

```bash
sudo apt-get install -y python3-pip
sudo pip3 install virtualenvwrapper
```

此时，必要的文件会被安装到`$HOME/.local/bin`

```bash
sudo mkdir -p /opt/python3-virtualenvwrapper
sudo mv -r $HOME/.local/bin/* /opt/python3-virtualenvwrapper
sudo chown -R root:root /opt/python3-virtualenvwrapper
```

设置环境变量并使其生效

```text
# Python3 Env
export WORKON_HOME=$HOME/.python3/virtualenvs
export PROJECT_HOME=$HOME/.python3/project
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV=/opt/python3-virtualenvwrapper/virtualenv
source /opt/python3-virtualenvwrapper/virtualenvwrapper.sh
```

基本命令:

```bash
# 创建新虚拟环境
mkvirtualenv <env-name>

# 退出虚拟环境
deactivate

# 列出所有虚拟环境
lsvirtualenv -l

# 删除虚拟环境
rmvirtualenv <env-name>

# 切换虚拟环境
workon <env-name>
```

## Ansible学习笔记

#### 安装

```bash
# MacOS
brew install ansible sshpass

# Ubuntu
sudo apt-get install -y ansible sshpass
```

#### 配置文件位置

* MacOS
    * `~/.ansible.cfg`
    * `~/.ansible/hosts`
* Linux
    * `/etc/ansible/ansible.cfg`
    * `/etc/ansible/hosts`

#### hosts模板

```text
[vm]
10.211.55.3 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='133810'

# -------------------------------------------------------------------------------------------------
# K8S集群
# -------------------------------------------------------------------------------------------------
[kubernetes]
192.168.99.111 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
192.168.99.112 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
192.168.99.113 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
192.168.99.116 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
192.168.99.122 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
192.168.99.123 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
192.168.99.124 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
192.168.99.125 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
192.168.99.126 ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
[kubernetes:vars]
ansible_python_interpreter=/usr/bin/python3

# -------------------------------------------------------------------------------------------------
# 其他
# -------------------------------------------------------------------------------------------------
[builder]
192.168.99.11[4:5] ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
[builder:vars]
ansible_python_interpreter=/usr/bin/python3

# -------------------------------------------------------------------------------------------------
# zookeeper kafka flume
# -------------------------------------------------------------------------------------------------
[zoo]
192.168.99.12[7:9] ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
[zoo:vars]
ansible_python_interpreter=/usr/bin/python3

# -------------------------------------------------------------------------------------------------
# hadoop hive hbase
# -------------------------------------------------------------------------------------------------
[hadoop]
192.168.99.13[0:2] ansible_connection=ssh ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='x'
[hadoop:vars]
ansible_python_interpreter=/usr/bin/python3

# -------------------------------------------------------------------------------------------------
# ccae公司所有
# -------------------------------------------------------------------------------------------------
[ccae:children]
kubernetes
builder
zoo
hadoop
```

#### 检查

```bash
ansible all -m ping
```

#### 常用模块

##### (1) Shell模块

##### (2) Script模块

##### (3) Copy模块

##### (4) Fetch模块

##### (5) File模块

##### (6) Unarchive模块

##### (7) Archive模块

##### (8) Hostname模块

##### (9) Cron模块

##### (10) Yum模块

##### (11) Apt模块

##### (12) Systemd模块

##### (13) User模块

##### (14) Group模块

##### (15) Lineinfile模块

##### (16) Replace模块

##### (17) Setup模块

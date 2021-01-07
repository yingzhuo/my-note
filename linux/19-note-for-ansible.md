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
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers.

#green.example.com
#blue.example.com
#192.168.100.1
#192.168.100.10

# Ex 2: A collection of hosts belonging to the 'webservers' group

#[webservers]
#alpha.example.org
#beta.example.org
#192.168.1.100
#192.168.1.110

# If you have multiple hosts following a pattern you can specify
# them like this:

#www[001:006].example.com

# Ex 3: A collection of database servers in the 'dbservers' group

#[dbservers]
#
#db01.intranet.mydomain.net
#db02.intranet.mydomain.net
#10.25.1.56
#10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

#db-[99:101]-node.example.com

#[ubuntu]
#10.211.55.3 ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass='xxxxxx'
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

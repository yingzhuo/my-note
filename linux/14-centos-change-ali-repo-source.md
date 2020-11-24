## CentOS设置阿里源

# 8

```bash
sudo mv /etc/yum.repos.d /etc/yum.repos.d.backup
sudo mkdir -p /etc/yum.repos.d/
sudo curl "http://mirrors.aliyun.com/repo/Centos-8.repo" -o /etc/yum.repos.d/CentOS-Base.repo
sudo yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm
sudo yum makecache
```

Remi (可选)

```bash
sudo yum install -y "https://mirrors.aliyun.com/remi/enterprise/remi-release-8.rpm"
```

## 在Linux上安装MariaDB

#### 安装

```bash
sudo apt-get install mariadb-server -y
```

#### 配置

```bash
# 设置root密码等
sudo mysql_secure_installation
```

```bash
sudo mariadb
```

```bash
MariaDB [(none)]> GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
MariaDB [(none)]> FLUSH PRIVILEGES;
```

编辑`/etc/mysql/mariadb.conf.d/50-server.cnf` 以下一行注释掉

```bash
bind-address            = 127.0.0.1 # 注释掉
```

```bash
sudo systemctl restart mariadb.service
```
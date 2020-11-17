## 在Linux上安装MySQL

#### 安装

```bash
sudo apt-get install -y mysql-server
```

#### 配置

```bash
# 设置root密码等
sudo mysql_secure_installation
```

```bash
mysql > GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
mysql > FLUSH PRIVILEGES;
```

编辑`/etc/mysql/xxx.d/50-server.cnf` 以下一行注释掉

```bash
bind-address            = 127.0.0.1 # 注释掉
```

```bash
sudo systemctl restart mysql.service
```

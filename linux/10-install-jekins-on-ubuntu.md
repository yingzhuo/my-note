## 在Linux上安装Jenkins

#### 安装Java

本人并不安装`OpenJDK`，而是安装`OracleJDK`。安装好以后，JAVA_HOME为`/var/lib/java8`

#### 安装Jenkins

```bash
wget –q –O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add –
echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update
apt install jenkins
```

#### 配置Jenkins

编辑`/etc/init.d/jenkins`配置PATH，注意把`/var/lib/java8/bin`加入PATH。

配置PORT等。

编辑`/etc/default/jenkins`即可。

#### 重启Jenkins

```bash
systemctl daemon-reload
systemctl restart jenkins
```

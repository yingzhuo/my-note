## 在Linux上安装harbor服务

#### 假设

harbor的ip地址为: `192.168.99.115`

#### 准备工作

[下载](https://github.com/goharbor/harbor/releases) harbor-offline-installer-v2.1.0.tgz，并解压到`/opt`。

#### 生成SSL秘钥

编辑`/etc/ssl/openssl.cnf`，在`[v3_ca]`段添加以下内容。

```bash
subjectAltName = IP:192.168.99.115
```

生成自签名秘钥

```bash
cd /tmp
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 3650 -out ca.crt
openssl req -newkey rsa:4096 -nodes -sha256 -keyout 192.168.99.115 -out 192.168.99.115
echo "subjectAltName = IP:192.168.99.115 > extfile.cnf"
openssl x509 -req -days 3650 -in 192.168.99.115 -CA ca.crt -CAkey ca.key -CAcreateserial -extfile extfile.cnf -out 192.168.99.115
sudo mkdir -p /etc/docker/certs.d/192.168.99.115
sudo cp *.crt *.key /etc/docker/certs.d/192.168.99.115
```

#### 启动harbor

```bash
cd /opt/harbor
```

编辑`harbor.yml.tmpl`

配置秘钥文件位置如下片段所示:

```yaml
https:
  port: 443
  certificate: /etc/docker/certs.d/192.168.99.115/ca.crt
  private_key: /etc/docker/certs.d/192.168.99.115/ca.key
```

```bash
cp harbor.yml.tmpl harbor.yml
./prepare
./install.sh
```

#### docker客户端如何应对自签名的证书

(1) MacOS (docker-desktop) 如果你用苹果机，你需要把ca.crt加入到钥匙串

```bash
security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain ca.crt
```

(2) Linux

```bash
sudo mkdir -p /etc/docker/certs.d/192.168.99.115/
sudo cp ./ca.crt /etc/docker/certs.d/192.168.99.115/ca.crt
```

## 解决docker-compose卡顿

#### Ubuntu

```bash
sudo apt-get install -y haveged
sudo echo 'DAEMON_ARGS="-w 1024"' > /etc/default/haveged
sudo update-rc.d haveged defaults
```

#### CentOS

```bash
sudo yum install -y haveged
sudo chkconfig haveged on
```

#### Test haveged

```bash
cat /proc/sys/kernel/random/entropy_avail
```

#### 参考资料

* [How to Setup Additional Entropy for Cloud Servers Using Haveged](https://www.digitalocean.com/community/tutorials/how-to-setup-additional-entropy-for-cloud-servers-using-haveged)

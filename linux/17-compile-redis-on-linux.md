## 在Linux上编译安装redis

#### (1) gcc 准备

```bash
# centos
sudo yum install -y gcc
gcc --version

# ubuntu
sudo yum install -y gcc
gcc --version
```

如果gcc版本号为`4.8.x` 则需要调整。

```bash
sudo yum install -y centos-release-scl devtoolset-7 llvm-toolset-7
scl enable devtoolset-7 llvm-toolset-7 bash
```

#### (2) 编译

```bash
wget "https://download.redis.io/releases/redis-6.0.9.tar.gz" -o redis.tgz
tar xzf redis.tgz
cd redis-6.0.9
make
```


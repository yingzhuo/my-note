## 通过源码方式安装zsh

#### (1) 下载源码并解压缩

[https://sourceforge.net/projects/zsh/](https://sourceforge.net/projects/zsh/)

#### (2) 安装必要的工具

* CentOS
    * `sudo yum install -y gcc make ncurses-devel`
* Ubuntu
    * `sudo apt-get install -y gcc make libncurses5-dev`
    
#### (3) 安装

```bash
su -
cd $SOURCE_CODE_DIR
./configure
make && make install
```

#### (4) 查看

```bash
/usr/local/bin/zsh --version
```

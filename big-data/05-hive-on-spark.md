## Hive On Spark

Hadoop Version: 3.1.4
Hive Version: 3.1.2
Spark Version: 2.4.7

#### 准备好编译环境

* JDK-1.8
* Maven-3.6.3

#### 编译Spark

(1) 在spark官方网站下载Spark源码

[地址](https://spark.apache.org/downloads.html)

(2) 编译

```bash
cd $SOURCE_DIR

./dev/make-distribution.sh \
    --name without-hive \
    --tgz \
    -Pyarn \
    -Phadoop-3.1 \
    -Dhadoop.version=3.1.4 \
    -Pparquet-provided \
    -Porc-provided \
    -Phadoop-provided
```

**注意:** 由于编译时需要用到谷歌的maven仓库，记得要科学上网。

#### 编译Hive

(1) 在官方网站下载Hive源码

[地址](https://hive.apache.org/downloads.html)

(2) 编译

```bash
cd $SOURCE_DIR

mvn clean package \
    -Dspark.version=2.4.7 \
    -Dhadoop.version=3.1.4 \
    -DskipTests \
    -Pdist
```

**注意:** 笔者实操好像并不需要科学上网，但是科学上网了也无妨。

#### (未完待续)

...

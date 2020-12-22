## sqoop cheat-sheet

### 数据导入

#### 全表导入到HDFS文件

```bash
sqoop import \
    --connect jdbc:mysql://10.211.55.3:3306/demo \
    --username root \
    --password root \
    --table employee \
    --delete-target-dir \
    --target-dir /sqoop-demo/employee \
    --split-by ',' \
    --null-string '\\N' \
    --null-non-string '\\N' \
    --num-mappers 1
```

#### 新增导入到HDFS文件 (按时间戳 - append模式)

```bash
sqoop import \
    --connect jdbc:mysql://10.211.55.3:3306/demo \
    --username root \
    --password root \
    --table employee \
    --target-dir /sqoop-demo/employee \
    --split-by ',' \
    --null-string '\\N' \
    --null-non-string '\\N' \
    --num-mappers 1 \
    --append \
    --incremental lastmodified \
    --check-column last_update \
    --last-value '2020-12-22 10:42:59'
```

**注意：** `last_update`字段已经要是时间戳类型，而不能是一般的`date`,`time`,`datetime`等类型。如下表的last_update就不错。

```sql
CREATE TABLE IF NOT EXISTS employee (
    `id` INT(20) PRIMARY KEY COMMENT 'ID',
    `name` VARCHAR(20) NOT NULL COMMENT '姓名',
    `salary` DOUBLE COMMENT '工资',
    `department` VARCHAR(20) COMMENT '部门名称',
    `email` VARCHAR(30) COMMENT '电子邮件地址',
    `last_update` TIMESTAMP DEFAULT current_timestamp on update current_timestamp COMMENT '最后更新时间'
)
COMMENT '员工表';
```

#### 新增导入到HDFS文件 (按时间戳 - merge-key模式)

```bash
sqoop import \
    --connect jdbc:mysql://10.211.55.3:3306/demo \
    --username root \
    --password root \
    --table employee \
    --target-dir /sqoop-demo/employee \
    --split-by ',' \
    --null-string '\\N' \
    --null-non-string '\\N' \
    --num-mappers 1 \
    --merge-key id \
    --incremental lastmodified \
    --check-column last_update \
    --last-value '2020-12-22 10:54:00'
```

**注意：** `last_update`字段已经要是时间戳类型，而不能是一般的`date`,`time`,`datetime`等类型。如下表的last_update就不错。

```sql
CREATE TABLE IF NOT EXISTS employee (
    `id` INT(20) PRIMARY KEY COMMENT 'ID',
    `name` VARCHAR(20) NOT NULL COMMENT '姓名',
    `salary` DOUBLE COMMENT '工资',
    `department` VARCHAR(20) COMMENT '部门名称',
    `email` VARCHAR(30) COMMENT '电子邮件地址',
    `last_update` TIMESTAMP DEFAULT current_timestamp on update current_timestamp COMMENT '最后更新时间'
)
COMMENT '员工表';
```

#### 新增导入到HDFS文件 (按ID)

```bash
sqoop import \
    --connect jdbc:mysql://10.211.55.3:3306/demo \
    --username root \
    --password root \
    --table employee \
    --target-dir /sqoop-demo/employee \
    --split-by ',' \
    --null-string '\\N' \
    --null-non-string '\\N' \
    --num-mappers 1 \
    --incremental append \
    --check-column id \
    --last-value 3
```

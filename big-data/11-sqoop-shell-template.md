## Sqoop脚本模板

```bash
#!/usr/bin/env bash
#------------------------------------------------------------------------------------------------------------
# 作者: 应卓
#------------------------------------------------------------------------------------------------------------

# ---
# 环境变量
# ---
export JAVA_HOME=/var/lib/java8
export SQOOP_HOME=/opt/sqoop
export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/hive

# ---
# 变量
# ---
application=datasotre-demo
sqoop=/opt/sqoop/bin/sqoop
hadoop=/opt/hadoop/bin/hadoop
db=jdbc:mysql://ubuntu:3306/data-warehouse-demo_business-sub-system
dbusername=root
dbpassword=root
_self="${0##*/}"

if [ "x$2" != "x" ]; then
    date=$2
else
    date=`date -d '-1 day' +%F`
fi

print_env() {
    echo "--------------------------------------------------------------------------------------------"
    echo "DATE        : $date"
    echo "SQOOP       : $sqoop"
    echo "HADOOP      : $hadoop"
    echo "DB          : $db"
    echo "DB-username : $dbusername"
    echo "DB-password : $dbpassword"
    echo "--------------------------------------------------------------------------------------------"
}

import_table() {
    # 导入数据
    $sqoop import \
        --connect $db \
        --username $dbusername \
        --password $dbpassword \
        --target-dir /$application/db/$1/$date \
        --delete-target-dir \
        --query "$2 and \$CONDITIONS" \
        --num-mappers 1 \
        --compress \
        --compression-codec lzop \
        --fields-terminated-by ',' \
        --null-string '\\N' \
        --null-non-string '\\N'

    # 生成lzo索引文件
    $hadoop jar \
        $HADOOP_HOME/share/hadoop/common/hadoop-lzo-0.4.20.jar \
        com.hadoop.compression.lzo.DistributedLzoIndexer \
        /$application/db/$1/$date
    
    # 删除垃圾文件
    rm -f ./*.java
}

import_table_t_user() {
    import_table \
        "t_user" \
        "
        SELECT
            id,
            name,
            username,
            phone_number,
            avatar_url,
            email_addr,
            gender,
            login_password,
            created_date,
            last_updated_date
        FROM
            t_user
        WHERE
            DATE_FORMAT(created_date, '%Y-%m-%d') = '$date'
        OR
            DATE_FORMAT(last_updated_date, '%Y-%m-%d') = '$date'
        "
}

import_table_t_cart_item() {
        import_table \
        "t_cart_item" \
        "
        SELECT
            id,
            commodity_id,
            commodity_name,
            commodity_price,
            commodity_discount,
            commodity_description,
            count,
            final_price,
            user_id,
            created_date,
            last_updated_date
        FROM
            t_cart_item
        WHERE
            1=1
        "
}

import_table_t_order_item() {
        import_table \
        "t_order_item" \
        "
        SELECT
            id,
            order_id,
            user_id,
            commodity_id,
            commodity_name,
            commodity_price,
            commodity_discount,
            commodity_description,
            count,
            final_price,
            created_date,
            last_updated_date
        FROM
            t_order_item
        WHERE
            DATE_FORMAT(created_date, '%Y-%m-%d') = '$date'
        "
}

case $1 in
    "__print_env")
        print_env
        ;;
    "__all")
        import_table_t_user
        import_table_t_cart_item
        import_table_t_order_item
        ;; 
    "t_user")
        import_table_t_user
        ;;
    "t_cart_item")
        import_table_t_cart_item
        ;;
    "t_order_item")
        import_table_t_order_item
        ;;
    *)
        echo "Usage:"
        echo "$_self <选项> <时间>"
        echo "  特殊选项:"
        echo "    __print_env : 打印环境变量等"
        echo "    __all       : 导入全部表"
esac
```
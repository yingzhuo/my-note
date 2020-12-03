## 在Linux上安装ActiveMQ集群

#### (1) 安装JDK

本文档不再赘述，安装好以后JAVA_HOME为: `/var/lib/java8`

#### (2) 安装

下载文件并解压到`/var/lib/activemq`目录。

配置环境变量

```bash
# activemq
export ACTIVEMQ_HOME=/var/lib/activemq
export PATH=$PATH:ACTIVEMQ_HOME/bin
```

#### (3) 准备数据目录

```bash
mkdir -p /var/data/activemq
chmod 777 /var/data/activemq
```

#### (4) 配置

`sudo vim $ACTIVEMQ_HOME/conf/activemq.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
  http://activemq.apache.org/schema/core http://activemq.apache.org/schema/core/activemq-core.xsd">

    <!-- Allows us to use system properties as variables in this configuration file -->
    <bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
        <property name="locations">
            <value>file:${activemq.conf}/credentials.properties</value>
        </property>
    </bean>

    <!-- Allows accessing the server log -->
    <bean id="logQuery" class="io.fabric8.insight.log.log4j.Log4jLogQuery"
          lazy-init="false" scope="singleton"
          init-method="start" destroy-method="stop">
    </bean>

    <!--
        The <broker> element is used to configure the ActiveMQ broker.
    -->
    <broker xmlns="http://activemq.apache.org/schema/core" brokerName="activemq" dataDirectory="${activemq.data}">
        <destinationPolicy>
            <policyMap>
                <policyEntries>
                    <policyEntry topic=">">
                        <!-- The constantPendingMessageLimitStrategy is used to prevent
                             slow topic consumers to block producers and affect other consumers
                             by limiting the number of messages that are retained
                             For more information, see:

                             http://activemq.apache.org/slow-consumer-handling.html
                        -->
                        <pendingMessageLimitStrategy>
                            <constantPendingMessageLimitStrategy limit="1000"/>
                        </pendingMessageLimitStrategy>
                    </policyEntry>
                </policyEntries>
            </policyMap>
        </destinationPolicy>

        <!--
            The managementContext is used to configure how ActiveMQ is exposed in
            JMX. By default, ActiveMQ uses the MBean server that is started by
            the JVM. For more information, see:

            http://activemq.apache.org/jmx.html
        -->
        <managementContext>
            <managementContext createConnector="false"/>
        </managementContext>

        <!--
            Configure message persistence for the broker. The default persistence
            mechanism is the KahaDB store (identified by the kahaDB tag).
            For more information, see:

            http://activemq.apache.org/persistence.html
        -->
        <persistenceAdapter>
            <replicatedLevelDB
                    directory="/var/data/activemq/db"
                    replicas="3"
                    bind="tcp://0.0.0.0:62623"
                    zkAddress="192.168.99.130:2181,192.168.99.131:2181,192.168.99.132:2181"
                    hostname="192.168.99.130"
                    zkPath="/var/data/activemq/zk"/>
        </persistenceAdapter>

        <!--
          The systemUsage controls the maximum amount of space the broker will
          use before disabling caching and/or slowing down producers. For more information, see:

          http://activemq.apache.org/producer-flow-control.html
        -->
        <systemUsage>
            <systemUsage>
                <memoryUsage>
                    <memoryUsage percentOfJvmHeap="70"/>
                </memoryUsage>
                <storeUsage>
                    <storeUsage limit="100 gb"/>
                </storeUsage>
                <tempUsage>
                    <tempUsage limit="50 gb"/>
                </tempUsage>
            </systemUsage>
        </systemUsage>

        <!--
            The transport connectors expose ActiveMQ over a given protocol to
            clients and other brokers. For more information, see:

            http://activemq.apache.org/configuring-transports.html
        -->
        <transportConnectors>
            <!-- DOS protection, limit concurrent connections to 1000 and frame size to 100MB -->
            <transportConnector name="openwire"
                                uri="tcp://0.0.0.0:61616?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="amqp"
                                uri="amqp://0.0.0.0:5672?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="stomp"
                                uri="stomp://0.0.0.0:61613?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="mqtt"
                                uri="mqtt://0.0.0.0:1883?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
            <transportConnector name="ws"
                                uri="ws://0.0.0.0:61614?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600"/>
        </transportConnectors>

        <!-- destroy the spring context on shutdown to stop jetty -->
        <shutdownHooks>
            <bean xmlns="http://www.springframework.org/schema/beans"
                  class="org.apache.activemq.hooks.SpringContextHook"/>
        </shutdownHooks>
    </broker>

    <!--
        Enable web consoles, REST and Ajax APIs and demos
        The web consoles requires by default login, you can disable this in the jetty.xml file
        Take a look at ${ACTIVEMQ_HOME}/conf/jetty.xml for more details
    -->
    <import resource="jetty.xml"/>
</beans>
```

注意:

* 同一个集群brokerName必须为一致的
* 每个节点要正确配置<persistenceAdapter/>标签

#### (4) 启动 / 关闭

```json
activemq start
activemq stop
```

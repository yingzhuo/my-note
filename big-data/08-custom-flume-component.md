## 自定义Flume组件

#### 依赖

```xml
<!-- flume-core -->
<dependency>
    <groupId>org.apache.flume</groupId>
    <artifactId>flume-ng-core</artifactId>
    <version>1.9.0</version>
</dependency>
```

#### Interceptor

```java
package com.github.yingzhuo.flume.demo;

import org.apache.flume.Context;
import org.apache.flume.Event;
import org.apache.flume.interceptor.Interceptor;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class HostnameAwareInterceptor implements Interceptor {

    private String hostname;

    public HostnameAwareInterceptor() {
        try {
            this.hostname = InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException e) {
            this.hostname = null;
        }
    }

    @Override
    public void initialize() {
    }

    @Override
    public Event intercept(Event event) {
        if (null == hostname) return event;

        final Map<String, String> headers = event.getHeaders();
        headers.put("flume-agent-hostname", this.hostname);
        return event;
    }

    @Override
    public List<Event> intercept(List<Event> events) {
        final List<Event> result = new ArrayList<>(events.size());

        for (Event event : events) {
            final Event e = this.intercept(event);
            result.add(e);
        }

        return result;
    }

    @Override
    public void close() {
    }

    // ------------------------------------------------------------------------------------------------------

    public static class Builder implements Interceptor.Builder {
        @Override
        public Interceptor build() {
            return new HostnameAwareInterceptor();
        }

        @Override
        public void configure(Context context) {
        }
    }

}
```

```properties
myagent.sources.mysource.interceptors = i1
myagent.sources.mysource.interceptors.i1.type = com.github.yingzhuo.flume.demo.HostnameAwareInterceptor$Builder
```

> **注意:** 自己的jar包要上传到`$FLUME_HOME/lib/`目录。并且要重启agent。

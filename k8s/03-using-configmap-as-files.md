## ConfigMap传递文件到POD

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: "playground"
---

apiVersion: v1
kind: ConfigMap
metadata:
  name: "configmap-files"
  namespace: "playground"
data:
  readme: |
    hello.
---

apiVersion: v1
kind: Pod
metadata:
  name: "playground"
  namespace: "playground"
spec:
  volumes:
    - name: configmap-files
      configMap:
        name: configmap-files
        optional: true
        items:
          - key: readme
            path: "README.md"
  containers:
    - name: default
      image: "192.168.99.115/yingzhuo/playground"
      volumeMounts:
        - name: configmap-files
          mountPath: "/home/java/config/"
```
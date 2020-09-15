### 删除Master的节点的污点使POD可以调度到其上。

```bash
kubectl taint node <node-name> node-role.kubernetes.io/master:NoSchedule-
```

### 修改NodePort Range

编辑 `/etc/kubernetes/manifests/kube-apiserver.yaml`

在`spec.containers.command`字段中添加如下配置，要注意格式

```bash
- --service-node-port-range=1-65535
```
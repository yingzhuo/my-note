### ✨安装kubeadm时指定版本号✨

```bash
# 删除旧版本
sudo apt autoremove --purge kubeadm kubectl kubelet kubernetes-cni

# 指定版本号安装
sudo apt-get install -y kubeadm=1.18.9-00 kubelet=1.18.9-00 kubectl=1.18.9-00

# 锁定版本号
sudo apt-mark hold kubeadm kubelet kubectl
sudo apt-mark showhold
# sudo apt-mark unhold kubeadm kubelet kubectl 解除锁定
```

### ✨删除Master的节点的污点使POD可以调度到其上✨

```bash
kubectl taint node <node-name> node-role.kubernetes.io/master:NoSchedule-
```

### ✨修改NodePort Range✨

编辑 `/etc/kubernetes/manifests/kube-apiserver.yaml`

在`spec.containers.command`字段中添加如下配置，要注意格式

```bash
- --service-node-port-range=1-65535
```

如果你的集群有多个master节点，每一个master节点都需要此操作。

### ✨为私有镜像仓库生成`ImagePullSecret`

请使用如下脚本 ↓↓↓↓

```bash
#!/bin/bash

# 生成secret
# 最后一个参数 --docker-email 是可选的，只是用用户名和密码也行
kubectl create secret docker-registry regcred \
    --docker-server=<your-registry-server> \
    --docker-username=<your-name> \
    --docker-password=<your-pword> \
    --docker-email=<your-email>

# 查看
kubectl get secret regcred -o yaml

# 删除不用的secret
kubectl get secret regcred -o yaml
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: harbor
  namespace: default
data:
  .dockerconfigjson: "<secret>"
type: kubernetes.io/dockerconfigjson
```

## 在不需要密码的情况下运行sudo命令

编辑`/etc/sudoers`

添加如下:

```text
<username>     ALL=(ALL) NOPASSWD:ALL
```

> **注意:** 需要重启session

### 更改hostname

##### (1) `sudo vim /etc/hostname`
##### (2) `sudo vim /etc/cloud/cloud.cfg`

```
preserve_hostname: true  # 第15行 false改成true
```
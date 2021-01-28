## 利用lantern翻墙

#### 函数

```bash
function lantern() {
  echo "开启lantern代理"
  export http_proxy=http://127.0.0.1:53774
  export https_proxy=http://127.0.0.1:53774

  git config --global http.proxy  http://127.0.0.1:53774
  git config --global https.proxy http://127.0.0.1:53774
}

function unlantern() {
  echo "关闭lantern代理"
  export http_proxy=""
  export https_proxy=""

  git config --global --unset http.proxy
  git config --global --unset https.proxy
}
```

#### 使用

```bash
lantern; curl "https://www.youtube.com/"
```

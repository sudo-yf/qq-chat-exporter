# macOS 使用手册

QCE 的 macOS 版通过菜单栏启动器控制，不再提供 Windows / Linux / Docker 文档。

## 启动

1. 解压项目
2. 双击 `打开真实QQ导出器.command`
3. 右上角会出现 QCE 菜单栏图标
4. 之后直接打开 `NapCat-QCE-macOS-arm64/QQ-QCE.app` 也会强制走这个菜单栏图标，不再绕过它
5. 点击图标选择：
   - 打开网页
   - 启动 QCE
   - 停止 QCE
   - 停止并退出

## 登录地址

默认页面是：

```text
http://127.0.0.1:40653/qce-v4-tool
```

## Access Token

- 令牌保存在 `~/.qq-chat-exporter/security.json`
- 字段名是 `accessToken`
- 菜单栏启动器会自动读取它并打开登录页

## 关闭

- 点击菜单栏图标，选择“停止并退出”
- 或双击 `关闭真实QQ导出器.command`

## 常见问题

### 浏览器提示 `ERR_CONNECTION_REFUSED`

通常表示 QCE 还没有启动成功。先看菜单栏图标是否正常，再刷新页面。

### 页面显示 404

这通常表示你打开了错误的地址。请确认访问的是 `http://127.0.0.1:40653/qce-v4-tool`。

### 想知道 token 在哪里

打开 `~/.qq-chat-exporter/security.json`，查看 `accessToken`。

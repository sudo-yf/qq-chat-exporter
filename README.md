# QQ Chat Exporter

QQ Chat Exporter（QCE）是一个 QQ 聊天记录导出工具，可将好友/群聊记录导出为 HTML、JSON、TXT、XLSX 等格式，并尽量保留图片、视频、文件等资源。

![预览图](./image.png)

> 这是一个带 macOS 优化的版本：增加了菜单栏启动器、Mac 风格 UI 和一键启动/停止能力。

## 主要特性

- 导出好友和群聊消息
- 支持 HTML / JSON / TXT / Excel
- 图片、视频、文件等媒体资源可一起导出
- 批量导出、定时备份
- macOS 菜单栏启动器：打开网页、启动、停止、退出
- Mac 风格前端界面优化

## 快速开始

### Windows / Linux

1. 前往 [Releases](https://github.com/sudo-yf/qq-chat-exporter/releases) 下载对应平台压缩包
2. 解压后运行：
   - Windows：`launcher-user.bat`
   - Linux：`./launcher-user.sh`
3. 打开 Web 界面 `http://127.0.0.1:40653/qce-v4-tool`，按终端输出的 Access Token 登录后开始导出

### macOS

1. 解压项目后，双击 `打开真实QQ导出器.command`
2. 右上角会出现菜单栏图标
3. 点击图标即可：
   - 打开网页
   - 启动 QCE
   - 停止 QCE
   - 停止并退出
4. 正常情况下不需要盯着 Terminal 窗口

> macOS 版会自动读取 `~/.qq-chat-exporter/security.json` 中的 accessToken。

## Web 入口

- 默认页面：`http://127.0.0.1:40653/qce-v4-tool`
- 如果页面打不开，先确认本机 QCE 是否已经启动

## Access Token

- Windows / Linux：启动后会在终端里输出 Access Token，也可以查看 `~/.qq-chat-exporter/security.json` 里的 `accessToken` 字段
- macOS：菜单栏启动器会自动读取 `~/.qq-chat-exporter/security.json`，通常不需要手动复制 token

## 文档

- 使用手册：`docs/guide.md`
- Docker NapCat 部署：`docs/docker-napcat-deployment.md`
- 问题反馈：`docs/feedback.md`
- 贡献指南：`docs/contributing.md`

## 项目结构

- `qce-v4-tool/`：前端 Web 界面
- `qce-statusbar/`：macOS 菜单栏启动器
- `NapCat-QCE-macOS-arm64/`：macOS 运行包
- `qce-viewer/`：导出的聊天记录查看器
- `docs/`：使用文档

## 致谢

感谢 [NapCatQQ](https://github.com/NapNeko/NapCatQQ) 团队提供的框架支持。

## 许可证

[GPL-3.0](https://github.com/sudo-yf/qq-chat-exporter/blob/main/LICENSE)

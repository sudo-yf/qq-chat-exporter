# QQ Chat Exporter

QQ Chat Exporter（macOS 版）是一个 QQ 聊天记录导出工具，可将好友/群聊记录导出为 HTML、JSON、TXT、XLSX 等格式，并尽量保留图片、视频、文件等资源。

![预览图](./image.png)

## 主要特性

- 只保留 macOS 支持
- 菜单栏启动器：打开网页、启动、停止、退出
- Mac 风格前端界面
- 支持 HTML / JSON / TXT / Excel 导出
- 支持批量导出、定时备份、资源打包

## 快速开始

1. 解压项目后，双击 `打开真实QQ导出器.command`
2. 右上角会出现 QCE 菜单栏图标
3. 之后即使直接打开 `NapCat-QCE-macOS-arm64/QQ-QCE.app`，也会先唤起同一个菜单栏图标
4. 点击图标即可打开网页或启动/停止服务
5. 默认地址：`http://127.0.0.1:40653/qce-v4-tool`

## Access Token

- 访问令牌会保存在 `~/.qq-chat-exporter/security.json`
- 正常情况下，菜单栏启动器会自动读取该文件并跳转到登录页

## 其他入口

- 关闭服务：`关闭真实QQ导出器.command`

## 文档

- 使用手册：`docs/guide.md`
- 问题反馈：`docs/feedback.md`
- 贡献指南：`docs/contributing.md`

## 项目结构

- `qce-v4-tool/`：前端 Web 界面
- `qce-statusbar/`：macOS 菜单栏启动器
- `NapCat-QCE-macOS-arm64/`：macOS 运行包

## 说明

Windows / Linux / Docker 相关文档和发布物已移除，不再维护。

## 致谢

感谢 [NapCatQQ](https://github.com/NapNeko/NapCatQQ) 团队提供的框架支持。

## 许可证

[GPL-3.0](https://github.com/sudo-yf/qq-chat-exporter/blob/main/LICENSE)

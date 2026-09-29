# Pinball

Pinball 让你的 macOS 桌面直接成为弹珠台。

屏幕边缘是挡板，正在打开的窗口是会移动的障碍。拖动左下角的发射器再松手，一颗弹珠就会从桌面上飞出去，在 Finder、浏览器和编辑器之间反弹；你挪动一个窗口，下一次碰撞的路线也会随之改变。

它以透明、可穿透点击的覆盖层存在，所以弹珠可以一直在玩，你也照样用自己的桌面。菜单栏负责暂停、重置和退出。这是一个把日常工作空间变成玩具的 macOS 实验。

## 运行

需要 macOS 14 或更新版本、Swift 6，以及安装在 `/Applications/Xcode.app` 的完整 Xcode。仓库目前提供源码构建方式：

```bash
./script/build_and_run.sh
```

脚本会构建 `dist/Pinball.app` 并打开它。**运行脚本会先结束正在运行的 Pinball 进程**；如果你正在调试旧实例，先保存相关工作。

启动后拖拽屏幕左下角的发射器并松开。菜单栏里可以暂停、重置弹珠或退出。脚本还支持 `--verify`、`--debug`、`--logs` 和 `--telemetry`，供开发时使用。

## 实现

桌面应用由 AppKit、SpriteKit 和 CoreGraphics 实现。它只读取本机可见窗口的元数据，用窗口矩形计算碰撞；没有服务端或网络请求。

`Package.swift` 只声明了 `PinballCore` 核心库及其测试。桌面 App 由 `script/build_and_run.sh` 单独编译和打包。若要运行核心库测试，可执行 `swift test`。

## 许可

代码采用 [MIT 许可证](LICENSE)。

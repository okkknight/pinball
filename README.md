# Pinball

一个 macOS 桌面弹珠实验：拖拽左下角的发射器并松开，弹珠会在透明、可点击穿透的覆盖层里运动，并与屏幕边缘和当前可见窗口的矩形边界碰撞。菜单栏可暂停、重置弹珠或退出。

项目使用 Swift、AppKit、SpriteKit 和 CoreGraphics。窗口扫描只在本机读取可见窗口的元数据以计算碰撞；仓库没有服务端或网络请求。

## 环境

- macOS 14 或更新版本
- Swift 6 和完整 Xcode，安装在默认的 `/Applications/Xcode.app` 路径

## 构建与运行

```bash
swift test
./script/build_and_run.sh
```

`swift test` 运行 `PinballCore` 的测试。脚本会构建并打开 `dist/Pinball.app`；它会先结束正在运行的 `Pinball` 进程，因此运行前请保存相关工作。脚本还支持 `--verify`、`--debug`、`--logs` 和 `--telemetry` 参数。

当前 `Package.swift` 只声明核心库和测试，桌面应用由 `script/build_and_run.sh` 单独编译、打包。

## 许可

代码采用 [MIT 许可证](LICENSE)。

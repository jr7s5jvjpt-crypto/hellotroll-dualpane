# DualPane / 双屏助手

TrollStore（巨魔）可用的 iOS 双窗口工具，目标环境 iOS 17.0，用 GitHub Actions 云端编译，不需要 Mac。

## 一、这个版本能干什么

- 左右分屏 / 上下分屏一键切换
- 中间分割线可拖动，自由调整两个窗口比例，一键恢复等宽
- 两个窗口各自独立：独立前进/后退/刷新、独立地址栏、独立浏览位置
- 底部边缘上滑唤起面板（另留「面板」按钮兜底），选入口塞进当前激活窗口
- 面板条目可增删改（标题 + 网址），本地持久化
- 点哪个窗口，哪个就是激活窗口（蓝色描边）
- 「自检」页：把系统版本、机型、私有框架类可见性打在屏幕上

## 二、怎么出 IPA

1. GitHub Desktop 里把本目录添加为仓库，Commit 后 Push 到 GitHub
2. 打开仓库 Actions 页，选 `build-ipa`
3. 等 3~6 分钟，Artifacts 下载 `DualPane-ipa`
4. 解压得到 `DualPane.ipa`，用 TrollStore 打开安装

流水线做的事：`xcodegen` 生成工程 → `xcodebuild` 免签编译 arm64 → `ldid` 用 `Resources/DualPane.entitlements` 假签名 → 打包 `Payload/DualPane.app` 成 ipa → 上传 artifact。

## 三、文件说明

```
project.yml                       XcodeGen 工程定义（包名、版本、arm64）
Resources/Info.plist              App 配置（含 ATS 允许任意网页）
Resources/DualPane.entitlements   假签名权限文件
Sources/AppDelegate.swift         启动
Sources/MainViewController.swift  主界面：分屏容器 + 底部操作栏 + 上滑唤起面板
Sources/SplitView.swift           双窗口布局、分割线拖动、方向切换
Sources/PaneView.swift            单个窗口：导航栏 + WKWebView
Sources/DockViewController.swift  上滑面板：选择 / 新增 / 删除条目
Sources/QuickEntry.swift          条目模型 + 本地持久化
Sources/ProbeViewController.swift 能力自检
.github/workflows/build-ipa.yml   云端打包流水线
```

## 四、常改的地方

| 想改什么 | 改哪里 |
|---|---|
| 包名 | `project.yml` 的 `PRODUCT_BUNDLE_IDENTIFIER` |
| App 名字 | `Resources/Info.plist` 的 `CFBundleDisplayName` |
| 默认打开的两个网页 | `Sources/QuickEntry.swift` 的 `defaultEntries` |
| 分屏比例范围 | `Sources/SplitView.swift` 里 0.25~0.75 的钳制 |
| 权限 | `Resources/DualPane.entitlements` |

## 五、已知限制

1. 只能巨魔装，普通签名/企业证书/App Store 都跑不了。
2. 窗口里跑的是 WebKit，不是系统原生 App；抖音、淘宝这类原生内容进不来，这是公开 API 的天花板。
3. 两个窗口共用一个 WKWebView 数据仓库，同站点双开可能共用登录态。
4. 部分网站禁止内嵌，会白屏，换网址即可。
5. 底部边缘上滑在个别机型会和系统手势抢响应，所以留了「面板」按钮兜底。

## 六、下一步

- 原生双 App 同屏：先跑「自检」页，把截图发回，按实际可见的私有类改写宿主代码
- 双数据仓库隔离（同一网站双账号）
- 授权模块（UUID 白名单 + 激活码），对外发的时候才需要

import UIKit

final class ProbeViewController: UIViewController {

    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "能力自检"

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "重跑",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(runProbe))

        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        runProbe()
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }

    @objc private func runProbe() {
        var lines: [String] = []
        lines.append("=== 设备 ===")
        lines.append("系统版本 : iOS \(UIDevice.current.systemVersion)")
        lines.append("机型     : \(Self.machineName())")
        lines.append("App 版本 : \(Self.appVersion())")
        lines.append("沙盒路径 : \(NSHomeDirectory())")
        lines.append("")

        lines.append("=== 环境探测 ===")
        let probePaths = [
            "/Applications/TrollStore.app",
            "/var/jb",
            "/var/containers/Bundle/Application",
            "/var/mobile/Library/Preferences/com.opa334.trollstore.plist"
        ]
        for path in probePaths {
            let exists = FileManager.default.fileExists(atPath: path)
            lines.append("\(exists ? "OK" : "NO") \(path)")
        }
        lines.append("")

        lines.append("=== 私有框架类可见性 ===")
        let classNames = [
            "FBSceneManager",
            "FBSSceneIdentity",
            "FBSSceneDefinition",
            "FBSMutableSceneDefinition",
            "FBSSceneSpecification",
            "FBSSceneSettings",
            "FBSSceneClientSettings",
            "FBSApplicationInfo",
            "FBApplicationLibrary",
            "FBSSystemService",
            "FBSOpenApplicationOptions",
            "LSApplicationWorkspace",
            "LSApplicationProxy",
            "RBSProcessPredicate",
            "BKSHIDEventDeliveryManager"
        ]
        var visibleCount = 0
        for name in classNames {
            let visible = NSClassFromString(name) != nil
            if visible { visibleCount += 1 }
            lines.append("\(visible ? "OK" : "NO") \(name)")
        }
        lines.append("")
        lines.append("可见类数量 : \(visibleCount) / \(classNames.count)")
        lines.append("")

        lines.append("=== 私有 UI 宿主类 ===")
        let uiClassNames = [
            "_UISceneHostingController",
            "_UISceneHostingView",
            "_UIRemoteView",
            "_UIWindowSceneHostingController"
        ]
        for name in uiClassNames {
            let visible = NSClassFromString(name) != nil
            lines.append("\(visible ? "OK" : "NO") \(name)")
        }
        lines.append("")
        lines.append("=== 结论 ===")
        lines.append("标 NO 的类在当前系统里不存在符号，")
        lines.append("做原生双 App 宿主时要换成替代接口。")
        lines.append("请把本页截图发回，我按结果调整工程。")

        textView.text = lines.joined(separator: "\n")
    }

    private static func machineName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            result.append(String(UnicodeScalar(UInt8(value))))
        }
        return identifier
    }

    private static func appVersion() -> String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }
}

import UIKit

final class MainViewController: UIViewController {

    private let splitView = SplitView(frame: .zero)
    private let bottomBar = UIView()
    private var entries: [QuickEntry] = QuickStore.load()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(splitView)
        buildBottomBar()
        view.addSubview(bottomBar)

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePan.edges = .bottom
        view.addGestureRecognizer(edgePan)

        loadInitialContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width = view.bounds.width
        let height = view.bounds.height
        let safeTop = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom
        let barHeight: CGFloat = 50

        let splitHeight = max(0, height - safeTop - safeBottom - barHeight)
        splitView.frame = CGRect(x: 0, y: safeTop, width: width, height: splitHeight)
        bottomBar.frame = CGRect(x: 0,
                                 y: safeTop + splitHeight,
                                 width: width,
                                 height: barHeight)
    }

    private func loadInitialContent() {
        if entries.count > 0 {
            splitView.panes[0].open(entries[0].url)
        } else {
            splitView.panes[0].open("https://www.baidu.com")
        }
        if entries.count > 1 {
            splitView.panes[1].open(entries[1].url)
        } else {
            splitView.panes[1].open("https://m.weibo.cn")
        }
    }

    private func buildBottomBar() {
        bottomBar.backgroundColor = .secondarySystemBackground

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -4)
        ])

        stack.addArrangedSubview(makeButton(title: "面板", symbol: "square.grid.2x2", action: #selector(dockTapped)))
        stack.addArrangedSubview(makeButton(title: "转向", symbol: "rectangle.split.2x1", action: #selector(rotateTapped)))
        stack.addArrangedSubview(makeButton(title: "等宽", symbol: "arrow.left.and.right", action: #selector(resetRatioTapped)))
        stack.addArrangedSubview(makeButton(title: "自检", symbol: "stethoscope", action: #selector(probeTapped)))
    }

    private func makeButton(title: String, symbol: String, action: Selector) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: symbol)
        configuration.imagePadding = 5
        configuration.baseForegroundColor = .label
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func dockTapped() {
        presentDock()
    }

    @objc private func rotateTapped() {
        splitView.toggleOrientation()
    }

    @objc private func resetRatioTapped() {
        splitView.ratio = 0.5
    }

    @objc private func probeTapped() {
        let probe = ProbeViewController()
        let navigation = UINavigationController(rootViewController: probe)
        present(navigation, animated: true)
    }

    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .ended {
            presentDock()
        }
    }

    private func presentDock() {
        let dock = DockViewController(entries: entries)

        dock.onPick = { [weak self] entry in
            guard let self = self else { return }
            let index = min(max(self.splitView.activeIndex, 0), self.splitView.panes.count - 1)
            self.splitView.panes[index].open(entry.url)
        }

        dock.onSave = { [weak self] newEntries in
            guard let self = self else { return }
            self.entries = newEntries
            QuickStore.save(newEntries)
        }

        let navigation = UINavigationController(rootViewController: dock)
        if let sheet = navigation.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 18
        }
        present(navigation, animated: true)
    }
}

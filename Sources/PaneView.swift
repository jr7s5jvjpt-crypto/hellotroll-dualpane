import UIKit
import WebKit

final class PaneView: UIView, WKNavigationDelegate, UITextFieldDelegate {

    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let reloadButton = UIButton(type: .system)
    private let addressField = UITextField()
    private let spinner = UIActivityIndicatorView(style: .medium)

    var onActivate: (() -> Void)?

    var isActive: Bool = false {
        didSet {
            layer.borderWidth = isActive ? 2.0 : 0.0
            layer.borderColor = isActive ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        clipsToBounds = true
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .onDrag

        topBar.backgroundColor = .secondarySystemBackground
        addSubview(topBar)
        addSubview(webView)

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        forwardButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        backButton.tintColor = .label
        forwardButton.tintColor = .label
        reloadButton.tintColor = .label

        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)

        addressField.delegate = self
        addressField.borderStyle = .roundedRect
        addressField.font = UIFont.systemFont(ofSize: 12)
        addressField.autocapitalizationType = .none
        addressField.autocorrectionType = .no
        addressField.keyboardType = .URL
        addressField.returnKeyType = .go
        addressField.clearButtonMode = .whileEditing
        addressField.textColor = .label
        addressField.backgroundColor = .systemBackground

        topBar.addSubview(backButton)
        topBar.addSubview(forwardButton)
        topBar.addSubview(reloadButton)
        topBar.addSubview(addressField)
        topBar.addSubview(spinner)

        let tap = UITapGestureRecognizer(target: self, action: #selector(activateTapped))
        tap.cancelsTouchesInView = false
        topBar.addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let barHeight: CGFloat = 38
        topBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: barHeight)
        webView.frame = CGRect(x: 0,
                               y: barHeight,
                               width: bounds.width,
                               height: max(0, bounds.height - barHeight))

        let side: CGFloat = 30
        let margin: CGFloat = 4
        backButton.frame = CGRect(x: margin, y: 4, width: side, height: side)
        forwardButton.frame = CGRect(x: margin + side, y: 4, width: side, height: side)
        reloadButton.frame = CGRect(x: margin + side * 2, y: 4, width: side, height: side)

        let fieldX = margin + side * 3 + 2
        let fieldWidth = max(50, bounds.width - fieldX - 30)
        addressField.frame = CGRect(x: fieldX, y: 4, width: fieldWidth, height: 30)
        spinner.frame = CGRect(x: bounds.width - 26, y: 9, width: 20, height: 20)
    }

    func open(_ urlString: String) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let normalized = trimmed.contains("://") ? trimmed : "https://" + trimmed
        guard let url = URL(string: normalized) else { return }
        addressField.text = url.absoluteString
        webView.load(URLRequest(url: url))
    }

    @objc private func goBack() {
        if webView.canGoBack { webView.goBack() }
    }

    @objc private func goForward() {
        if webView.canGoForward { webView.goForward() }
    }

    @objc private func reload() {
        if webView.url != nil {
            webView.reload()
        } else if let text = addressField.text {
            open(text)
        }
    }

    @objc private func activateTapped() {
        onActivate?()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        open(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.startAnimating()
        refreshNavigationState()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
        refreshNavigationState()
        if let url = webView.url?.absoluteString {
            addressField.text = url
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
        refreshNavigationState()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
        refreshNavigationState()
    }

    private func refreshNavigationState() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        backButton.alpha = webView.canGoBack ? 1.0 : 0.35
        forwardButton.alpha = webView.canGoForward ? 1.0 : 0.35
    }
}

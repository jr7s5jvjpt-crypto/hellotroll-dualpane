import UIKit

final class SplitView: UIView {

    enum Orientation {
        case sideBySide
        case topBottom
    }

    private(set) var panes: [PaneView] = [PaneView(frame: .zero), PaneView(frame: .zero)]

    var orientation: Orientation = .sideBySide {
        didSet {
            setNeedsLayout()
            UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
        }
    }

    var ratio: CGFloat = 0.5 {
        didSet {
            ratio = min(0.75, max(0.25, ratio))
            setNeedsLayout()
        }
    }

    var activeIndex: Int = 0 {
        didSet { refreshActive() }
    }

    private let divider = UIView()
    private let grip = UIView()
    private var dragStartRatio: CGFloat = 0.5
    private let dividerThickness: CGFloat = 12

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        clipsToBounds = true

        divider.backgroundColor = .separator
        grip.backgroundColor = .tertiaryLabel
        grip.layer.cornerRadius = 2
        divider.addSubview(grip)

        addSubview(panes[0])
        addSubview(panes[1])
        addSubview(divider)

        for (index, pane) in panes.enumerated() {
            pane.onActivate = { [weak self] in
                self?.activeIndex = index
            }
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        divider.addGestureRecognizer(pan)
        divider.isUserInteractionEnabled = true

        refreshActive()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func toggleOrientation() {
        orientation = (orientation == .sideBySide) ? .topBottom : .sideBySide
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let bounds = self.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        switch orientation {
        case .sideBySide:
            let usable = max(0, bounds.width - dividerThickness)
            let firstWidth = floor(usable * ratio)
            panes[0].frame = CGRect(x: 0, y: 0, width: firstWidth, height: bounds.height)
            divider.frame = CGRect(x: firstWidth, y: 0, width: dividerThickness, height: bounds.height)
            panes[1].frame = CGRect(x: firstWidth + dividerThickness,
                                    y: 0,
                                    width: usable - firstWidth,
                                    height: bounds.height)
            grip.frame = CGRect(x: (dividerThickness - 4) / 2,
                                y: (bounds.height - 40) / 2,
                                width: 4,
                                height: 40)

        case .topBottom:
            let usable = max(0, bounds.height - dividerThickness)
            let firstHeight = floor(usable * ratio)
            panes[0].frame = CGRect(x: 0, y: 0, width: bounds.width, height: firstHeight)
            divider.frame = CGRect(x: 0, y: firstHeight, width: bounds.width, height: dividerThickness)
            panes[1].frame = CGRect(x: 0,
                                    y: firstHeight + dividerThickness,
                                    width: bounds.width,
                                    height: usable - firstHeight)
            grip.frame = CGRect(x: (bounds.width - 40) / 2,
                                y: (dividerThickness - 4) / 2,
                                width: 40,
                                height: 4)
        }
    }

    private func refreshActive() {
        for (index, pane) in panes.enumerated() {
            pane.isActive = (index == activeIndex)
        }
    }

    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            dragStartRatio = ratio
        case .changed, .ended:
            let translation = gesture.translation(in: self)
            let delta: CGFloat
            if orientation == .sideBySide {
                delta = bounds.width > 0 ? translation.x / bounds.width : 0
            } else {
                delta = bounds.height > 0 ? translation.y / bounds.height : 0
            }
            ratio = dragStartRatio + delta
        default:
            break
        }
    }
}

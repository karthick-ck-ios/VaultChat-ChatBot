//
//  VaultChatFloatingButton.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//

import UIKit
import SwiftUI

public enum FloatingButtonPlacement {
    case bottomTrailing
    case bottomLeading
    case topTrailing
    case topLeading
}

public struct FloatingButtonOptions {
    public var placement: FloatingButtonPlacement
    public var horizontalPadding: CGFloat?
    public var verticalPadding: CGFloat?
    public var avoidKeyboard: Bool
    public var autoHideOnScroll: Bool
    public weak var scrollView: UIScrollView?
    public var enableDragToReposition: Bool

    public init(
        placement: FloatingButtonPlacement = .bottomTrailing,
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        avoidKeyboard: Bool = true,
        autoHideOnScroll: Bool = false,
        scrollView: UIScrollView? = nil,
        enableDragToReposition: Bool = false
    ) {
        self.placement = placement
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.avoidKeyboard = avoidKeyboard
        self.autoHideOnScroll = autoHideOnScroll
        self.scrollView = scrollView
        self.enableDragToReposition = enableDragToReposition
    }
}

public final class VaultChatFloatingButton: UIButton {

    private let manager = VaultChatManager.shared

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        applyConfiguration()
    }

    // MARK: - Config

    public func applyConfiguration() {
        guard let config = manager.configuration else {
            isHidden = true
            return
        }
        isHidden = false

        // Remove any previous intrinsic size constraints so we don’t duplicate
        constraints.filter {
            ($0.firstAttribute == .width || $0.firstAttribute == .height) && $0.relation == .equal
        }.forEach { $0.isActive = false }

        // Size
        let side = config.floatingButtonSize
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: side),
            heightAnchor.constraint(equalToConstant: side)
        ])

        backgroundColor = UIColor(config.primaryColor)
        layer.cornerRadius = config.buttonShape == .circle ? side / 2 : 12

        // Content
        setTitle(nil, for: .normal)
        setImage(nil, for: .normal)
        subviews.filter { $0 is UIImageView || $0 is UILabel }.forEach { $0.removeFromSuperview() }

        switch config.buttonType {
        case .text:
            setTitle(config.buttonContent, for: .normal)
            setTitleColor(.white, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        case .image:
            let img = UIImage(systemName: config.buttonContent)
            let imageView = UIImageView(image: img)
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
            ])
        }
    }

    // MARK: - Actions

    @objc private func handleTap() {
        guard let presenter = findTopMostViewController() else { return }
        guard let config = manager.configuration else { return }

        if config.apiKey.isEmpty {
            showConfigurationAlert(from: presenter)
            return
        }

        let vc = ChatViewController(viewModel: ChatViewModel())
        let nav = UINavigationController(rootViewController: vc)
        presenter.present(nav, animated: true, completion: nil)
        VaultChatManager.shared.openChat()
    }

    private func showConfigurationAlert(from presenter: UIViewController) {
        let alert = UIAlertController(
            title: "Configuration Error",
            message: "The API key is invalid. Please enter a valid API key to continue.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        presenter.present(alert, animated: true, completion: nil)
    }

    // MARK: - Helpers

    private func findTopMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return findTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return findTopMostViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return findTopMostViewController(base: presented)
        }
        return base
    }
}

// MARK: - UIViewController convenience

private final class FloatingButtonCoordinator: NSObject, UIGestureRecognizerDelegate {
    weak var button: VaultChatFloatingButton?
    weak var hostView: UIView?
    weak var scrollView: UIScrollView?

    var leadingConstraint: NSLayoutConstraint?
    var trailingConstraint: NSLayoutConstraint?
    var topConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?

    var baseBottomConstant: CGFloat = 0
    var baseTopConstant: CGFloat = 0

    var options: FloatingButtonOptions
    var keyboardObserverTokens: [NSObjectProtocol] = []

    init(button: VaultChatFloatingButton, hostView: UIView, options: FloatingButtonOptions) {
        self.button = button
        self.hostView = hostView
        self.options = options
        self.scrollView = options.scrollView
        super.init()
    }

    func installConstraints() {
        guard let host = hostView, let button = button else { return }
        let guide = host.safeAreaLayoutGuide

        // Clean old constraints
        [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint].forEach { $0?.isActive = false }

        let defaultH = VaultChatManager.shared.configuration?.trailingPadding ?? 16
        let defaultV = VaultChatManager.shared.configuration?.bottomPadding ?? 24
        let hPad = options.horizontalPadding ?? defaultH
        let vPad = options.verticalPadding ?? defaultV

        switch options.placement {
        case .bottomTrailing:
            trailingConstraint = button.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -hPad)
            bottomConstraint = button.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -vPad)
            baseBottomConstant = -vPad
            trailingConstraint?.isActive = true
            bottomConstraint?.isActive = true

        case .bottomLeading:
            leadingConstraint = button.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: hPad)
            bottomConstraint = button.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -vPad)
            baseBottomConstant = -vPad
            leadingConstraint?.isActive = true
            bottomConstraint?.isActive = true

        case .topTrailing:
            trailingConstraint = button.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -hPad)
            topConstraint = button.topAnchor.constraint(equalTo: guide.topAnchor, constant: vPad)
            baseTopConstant = vPad
            trailingConstraint?.isActive = true
            topConstraint?.isActive = true

        case .topLeading:
            leadingConstraint = button.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: hPad)
            topConstraint = button.topAnchor.constraint(equalTo: guide.topAnchor, constant: vPad)
            baseTopConstant = vPad
            leadingConstraint?.isActive = true
            topConstraint?.isActive = true
        }
    }

    func setupKeyboardAvoidance() {
        guard options.avoidKeyboard else { return }
        let willShow = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self, let host = self.hostView else { return }
            guard let userInfo = note.userInfo,
                  let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return }

            let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)
            let kbHeight = frame.height

            if let bottom = self.bottomConstraint {
                bottom.constant = self.baseBottomConstant - kbHeight + host.safeAreaInsets.bottom
            }
            UIView.animate(withDuration: duration, delay: 0, options: curve) {
                host.layoutIfNeeded()
            }
        }

        let willHide = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self, let host = self.hostView else { return }
            guard let userInfo = note.userInfo,
                  let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return }

            let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)
            if let bottom = self.bottomConstraint {
                bottom.constant = self.baseBottomConstant
            }
            UIView.animate(withDuration: duration, delay: 0, options: curve) {
                host.layoutIfNeeded()
            }
        }

        keyboardObserverTokens = [willShow, willHide]
    }

    func setupScrollAutoHide() {
        guard options.autoHideOnScroll, let scrollView = scrollView, let button = button else { return }
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollPan(_:)))
        // Initial visible
        button.alpha = 1
    }

    @objc private func handleScrollPan(_ gesture: UIPanGestureRecognizer) {
        guard let button = button else { return }
        switch gesture.state {
        case .changed:
            let velocity = gesture.velocity(in: gesture.view)
            let goingDown = velocity.y > 0
            UIView.animate(withDuration: 0.2) {
                button.alpha = goingDown ? 1 : 0.2
            }
        case .ended, .cancelled, .failed:
            UIView.animate(withDuration: 0.2) {
                button.alpha = 1
            }
        default:
            break
        }
    }

    func setupDragToReposition() {
        guard options.enableDragToReposition, let button = button, let host = hostView else { return }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        pan.delegate = self
        button.addGestureRecognizer(pan)
    }

    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let host = hostView, let button = button else { return }
        let translation = gesture.translation(in: host)
        gesture.setTranslation(.zero, in: host)

        switch gesture.state {
        case .began, .changed:
            let center = button.center
            var newCenter = CGPoint(x: center.x + translation.x, y: center.y + translation.y)

            // Keep inside safe area
            let guideFrame = host.safeAreaLayoutGuide.layoutFrame
            let halfW = button.bounds.width / 2
            let halfH = button.bounds.height / 2
            newCenter.x = max(guideFrame.minX + halfW, min(guideFrame.maxX - halfW, newCenter.x))
            newCenter.y = max(guideFrame.minY + halfH, min(guideFrame.maxY - halfH, newCenter.y))

            // When dragging, deactivate anchor constraints to allow free movement
            [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint].forEach { $0?.isActive = false }
            button.center = newCenter
        default:
            break
        }
    }

    deinit {
        keyboardObserverTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }
}

public extension UIViewController {

    // Adds a floating chat button configured with options (SwiftUI-like ergonomics).
    @discardableResult
    func addVaultChatFloatingButton(options: FloatingButtonOptions = FloatingButtonOptions()) -> VaultChatFloatingButton {
        let button = VaultChatFloatingButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        let coordinator = FloatingButtonCoordinator(button: button, hostView: view, options: options)
        objc_setAssociatedObject(button, &AssociatedKeys.coordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        coordinator.installConstraints()
        coordinator.setupKeyboardAvoidance()
        coordinator.setupScrollAutoHide()
        coordinator.setupDragToReposition()

        return button
    }

    // Backward-compatible API (defaults to bottomTrailing with config paddings).
    @discardableResult
    func addVaultChatFloatingButton() -> VaultChatFloatingButton {
        addVaultChatFloatingButton(options: FloatingButtonOptions())
    }
}

private enum AssociatedKeys {
    static var coordinatorKey: UInt8 = 0
}

private extension UIColor {
    convenience init(_ color: Color) {
        // Bridge SwiftUI.Color to UIColor via cgColor if available; otherwise fallback render
        if let cg = color.cgColor {
            self.init(cgColor: cg)
            return
        }
        let hosting = UIHostingController(rootView: Rectangle().fill(color))
        hosting.view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: hosting.view.bounds.size)
        let image = renderer.image { _ in
            hosting.view.drawHierarchy(in: hosting.view.bounds, afterScreenUpdates: true)
        }
        self.init(patternImage: image)
    }
}

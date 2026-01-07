//
//  ChatViewController.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//

import UIKit
import Combine
import SwiftUI

public final class ChatViewController: UIViewController {

    private let manager = VaultChatManager.shared
    private let viewModel: ChatViewModel

    // UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputContainer = UIView()
    private let divider = UIView()
    private let navDivider = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let activity = UIActivityIndicatorView(style: .medium)
    private var bottomConstraint: NSLayoutConstraint?

    // Combine
    private var cancellables = Set<AnyCancellable>()

    public init(viewModel: ChatViewModel = ChatViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupKeyboardHandling()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Apply theme on UIKit side as well
        if let config = manager.configuration {
            applyTheme(config.theme)
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Navigation
        title = manager.configuration?.chatTitle ?? "Powered by VaultChat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        // Table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: ChatBubbleCell.reuseID)
        view.addSubview(tableView)

        // Nav divider under navigation bar
        navDivider.translatesAutoresizingMaskIntoConstraints = false
        navDivider.backgroundColor = .separator
        view.addSubview(navDivider)

        // Input bar
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = .systemBackground
        view.addSubview(inputContainer)

        // Divider line at top of inputContainer
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .separator
        inputContainer.addSubview(divider)

        // TextField
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Type a message..."
        textField.borderStyle = .none
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 27.5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.cgColor
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode = .always

        // Send button
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = UIColor(manager.configuration?.primaryColor ?? .blue)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.layer.cornerRadius = 25
        sendButton.backgroundColor = UIColor((manager.configuration?.primaryColor.opacity(0.2)) ?? Color.gray.opacity(0.2))

        // Activity
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.hidesWhenStopped = true

        // Stack
        let hStack = UIStackView(arrangedSubviews: [textField, sendButton])
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(hStack)
        sendButton.addSubview(activity)

        // Constraints
        let guide = view.safeAreaLayoutGuide
        bottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor)

        NSLayoutConstraint.activate([
            // Nav divider pinned to safe area top
            navDivider.topAnchor.constraint(equalTo: guide.topAnchor),
            navDivider.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            navDivider.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            navDivider.heightAnchor.constraint(equalToConstant: 0.5),

            // Table between nav divider and input container
            tableView.topAnchor.constraint(equalTo: navDivider.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),

            inputContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            bottomConstraint!,
            inputContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),

            // Divider constraints
            divider.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            divider.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            // Stack constraints (below divider)
            hStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -12),
            hStack.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),

            textField.heightAnchor.constraint(equalToConstant: 55),

            activity.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
        ])
    }

    private func bindViewModel() {
        // Bind text field to viewModel.inputText
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField)
            .compactMap { ($0.object as? UITextField)?.text }
            .sink { [weak self] text in
                self?.viewModel.inputText = text
                self?.updateSendButtonState()
            }
            .store(in: &cancellables)

        // Observe messages to reload
        viewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.scrollToBottom(animated: true)
            }
            .store(in: &cancellables)

        // Observe loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.setLoading(isLoading)
            }
            .store(in: &cancellables)

        // Keep text field text in sync if viewModel changes (e.g., clears after send)
        viewModel.$inputText
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                if self?.textField.text != text {
                    self?.textField.text = text
                }
                self?.updateSendButtonState()
            }
            .store(in: &cancellables)
    }

    private func updateSendButtonState() {
        let trimmed = viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let canSend = !trimmed.isEmpty && !viewModel.isLoading
        sendButton.isEnabled = canSend

        let primary = UIColor(manager.configuration?.primaryColor ?? .blue)
        let bg = trimmed.isEmpty ? UIColor.systemGray5 : primary.withAlphaComponent(0.2)
        let tint = trimmed.isEmpty ? UIColor.systemGray : primary

        sendButton.backgroundColor = bg
        sendButton.tintColor = tint
    }

    private func setLoading(_ loading: Bool) {
        textField.isEnabled = !loading
        sendButton.isEnabled = !loading && !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if loading {
            activity.startAnimating()
        } else {
            activity.stopAnimating()
        }
    }

    @objc private func sendTapped() {
        view.endEditing(true)
        viewModel.send()
    }

    @objc private func closeTapped() {
        manager.closeChat()
        // If presented modally, dismiss. If pushed, pop.
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func scrollToBottom(animated: Bool) {
        let count = tableView.numberOfRows(inSection: 0)
        guard count > 0 else { return }
        let idx = IndexPath(row: count - 1, section: 0)
        tableView.scrollToRow(at: idx, at: .bottom, animated: animated)
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func kbWillShow(_ note: Notification) {
        guard
            let userInfo = note.userInfo,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)
        bottomConstraint?.constant = -frame.height + view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration, delay: 0, options: curve) {
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: false)
        }
    }

    @objc private func kbWillHide(_ note: Notification) {
        guard
            let userInfo = note.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)
        bottomConstraint?.constant = 0
        UIView.animate(withDuration: duration, delay: 0, options: curve) {
            self.view.layoutIfNeeded()
        }
    }

    private func applyTheme(_ theme: VaultChatTheme) {
        switch theme {
        case .light:
            overrideUserInterfaceStyle = .light
        case .dark:
            overrideUserInterfaceStyle = .dark
        case .system:
            overrideUserInterfaceStyle = .unspecified
        }
    }
}

// MARK: - UITableView

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = viewModel.messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleCell.reuseID, for: indexPath) as! ChatBubbleCell
        cell.configure(with: message, primaryColor: UIColor(manager.configuration?.primaryColor ?? .blue))
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - Bubble cell

private final class ChatBubbleCell: UITableViewCell {

    static let reuseID = "ChatBubbleCell"

    private let bubble = UIView()
    private let label = UILabel()
    private var leadingEqual: NSLayoutConstraint!
    private var trailingEqual: NSLayoutConstraint!
    private var leadingLTE: NSLayoutConstraint!
    private var trailingLTE: NSLayoutConstraint!
    private var maxWidth: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.layer.cornerRadius = 12
        contentView.addSubview(bubble)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        contentView.addSubview(label)

        // Equal constraints to anchor bubble to either side
        leadingEqual = bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingEqual = bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        // "Safety" constraints to keep bubble from exceeding content width
        leadingLTE = bubble.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16)
        trailingLTE = bubble.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)

        // Max width for wrapping
        maxWidth = bubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.85)

        NSLayoutConstraint.activate([
            // Keep vertical padding
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Label inside bubble
            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -12),

            // Always-active constraints
            leadingLTE,
            trailingLTE,
            maxWidth
        ])

        // Start with a neutral state; configure() will activate the correct side
        leadingEqual.isActive = false
        trailingEqual.isActive = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: ChatMessage, primaryColor: UIColor) {
        label.text = message.text

        // Activate only one side's equal constraint and deactivate the other
        if message.isUser {
            // Right aligned bubble
            leadingEqual.isActive = false
            trailingEqual.isActive = true

            bubble.backgroundColor = primaryColor
            label.textColor = .white
        } else {
            // Left aligned bubble
            trailingEqual.isActive = false
            leadingEqual.isActive = true

            bubble.backgroundColor = UIColor.secondarySystemFill
            label.textColor = .label
        }

        // Ensure layout recalculates with new constraints
        setNeedsUpdateConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset side anchoring; configure will set it appropriately
        leadingEqual.isActive = false
        trailingEqual.isActive = false
        label.text = nil
    }
}

//private extension UIColor {
//    // Correct bridge from SwiftUI.Color to UIKit.UIColor (iOS 14+)
//    convenience init(_ color: Color) {
//        self.init(color)
//    }
//}

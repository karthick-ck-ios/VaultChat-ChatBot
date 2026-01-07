//
//  VaultChatUIKitPresenter.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//

import UIKit

public enum VaultChatUIKitPresenter {

    public static func present(from presenter: UIViewController,
                               viewModel: ChatViewModel = ChatViewModel(),
                               animated: Bool = true) {
        let vc = ChatViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        presenter.present(nav, animated: animated)
    }

    public static func push(on nav: UINavigationController,
                            viewModel: ChatViewModel = ChatViewModel(),
                            animated: Bool = true) {
        let vc = ChatViewController(viewModel: viewModel)
        nav.pushViewController(vc, animated: animated)
    }
}

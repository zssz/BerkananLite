//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import SwiftUI
import BerkananSDK
import StoreKit
import Combine

class MessagesViewController: UIHostingController<AnyView> {
  
  // Used to prompt user for review
  private static var numberOfSentMessages = 0
  
  override var keyCommands: [UIKeyCommand]? {
    return [
      UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(hidePreferences))
    ]
  }
  
  @objc func hidePreferences() {
    ApplicationController.shared.userData.showsPreferences = false
  }
  
  // TODO: remove this when `Text` will get clickable links
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let availableWidth = view.bounds.size.width - view.layoutMargins.left - view.layoutMargins.right + 2
    ApplicationController.shared.userData.maxWidth = availableWidth
  }
  
  #if !targetEnvironment(macCatalyst) && !os(tvOS)
  
  private var textDidChangeNotificationCanceller: AnyCancellable?
  
  private var userDataComposedTextChangeCanceller: AnyCancellable?
  
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override var inputAccessoryView: UIView? {
    if let presentedViewController = self.presentedViewController, !presentedViewController.isBeingDismissed {
      return nil
    }
    return messageInputView
  }
  
  lazy public var messageInputView: MessageInputView? = {
    let view = self.nibBundle?.loadNibNamed("MessageInputView", owner: self, options: nil)?.first as? MessageInputView
    view?.sendButton.addTarget(self, action: #selector(handleTapSendButton), for: .touchUpInside)
    view?.textField.clearsOnBeginEditing = false
    view?.textField.text = ApplicationController.shared.userData.composedText
    return view
  }()
      
  override init(rootView: AnyView) {
    super.init(rootView: rootView)
    self.commonInit()
  }
  
  @objc required dynamic init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  private func commonInit() {
    self.configureMessageInputView()
    self.textDidChangeNotificationCanceller = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.messageInputView?.textField).sink { [weak self] notification in
      guard let self = self else { return }
      ApplicationController.shared.userData.composedText = self.messageInputView?.textField.text ?? ""
      self.configureMessageInputView()
    }
    self.userDataComposedTextChangeCanceller = ApplicationController.shared.userData.$composedText.sink { [weak self] (value) in
      guard let self = self else { return }
      self.messageInputView?.textField.text = value
      DispatchQueue.main.async {
        self.configureMessageInputView()
      }
    }
  }
  
  private func configureMessageInputView() {
    let text = ApplicationController.shared.userData.composedText
    let isPDUTooBig = ApplicationController.shared.isMessageTooLong(for: text)
    messageInputView?.textField.textColor = isPDUTooBig ? .systemRed : .label
    messageInputView?.sendButton.isHidden = text.isEmpty
    messageInputView?.setNeedsLayout()
    UIView.animate(withDuration: 0.2) {
      self.messageInputView?.layoutIfNeeded()
    }
  }
  
  @objc func handleTapSendButton() {
    let text = ApplicationController.shared.userData.composedText
    ApplicationController.shared.send(text)
    messageInputView?.textField.resignFirstResponder()
  }
  
  #endif
}

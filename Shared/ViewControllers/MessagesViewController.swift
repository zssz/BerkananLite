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
    AppDelegate.shared?.userData.showsPreferences = false
  }
  
  // TODO: remove this when `Text` will get clickable links
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let availableWidth = view.bounds.size.width - view.layoutMargins.left - view.layoutMargins.right + 2
    AppDelegate.shared?.userData.maxWidth = availableWidth
  }
  
  #if !targetEnvironment(macCatalyst)
  
  private var textDidChangeNotificationCanceller: AnyCancellable?
  
  private var userDataChangeCanceller: AnyCancellable?
  
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
    view?.textField.text = AppDelegate.shared?.userData.composedText
    textDidChangeNotificationCanceller = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: view?.textField).sink { [weak self] notification in
      guard let self = self else { return }
      AppDelegate.shared?.userData.composedText = self.messageInputView?.textField.text ?? ""
      self.configureMessageInputView()
    }
    // Use async to not get into recursive trap when initializing
    DispatchQueue.main.async {
      self.configureMessageInputView()
    }
    userDataChangeCanceller = AppDelegate.shared?.userData.objectWillChange.sink(receiveValue: { [weak self] (value) in
      // Use async so object has the change already
      DispatchQueue.main.async {
        guard let self = self else { return }
        if self.messageInputView?.textField.text != AppDelegate.shared?.userData.composedText {
          self.messageInputView?.textField.text = AppDelegate.shared?.userData.composedText
          self.configureMessageInputView()
        }
      }
    })
    return view
  }()
  
  private func configureMessageInputView() {
    guard let appDelegate = AppDelegate.shared else { return }
    let text = AppDelegate.shared?.userData.composedText ?? ""
    let isPDUTooBig = appDelegate.isMessageTooBig(for: text)
    messageInputView?.textField.textColor = isPDUTooBig ? .systemRed : .label
    messageInputView?.sendButton.isHidden = text.isEmpty
    messageInputView?.setNeedsLayout()
    UIView.animate(withDuration: 0.2) {
      self.messageInputView?.layoutIfNeeded()
    }
  }
    
  @objc func handleTapSendButton() {
    guard let text = AppDelegate.shared?.userData.composedText else { return }
    AppDelegate.shared?.send(text)
    messageInputView?.textField.resignFirstResponder()
  }
  
  #endif
}

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

class MessagesViewController: UIHostingController<AnyView> {
  
  private static var numberOfSentMessages = 0
  
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
    return view
  }()
  
  @objc func handleTapSendButton() {
    guard let text = messageInputView?.textField.text else { return }
    guard let service = (UIApplication.shared.delegate as? AppDelegate)?.berkananBluetoothService else { return }
    
    let status = service.bluetoothAuthorization
    guard status == .allowedAlways else {
      let message = (status == .denied) ? NSLocalizedString("Access to Bluetooth denied.", comment: "") : NSLocalizedString("Access to Bluetooth restricted.", comment: "")
      let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
      if status == .denied {
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (action) in
          guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
          self.view.window?.windowScene?.open(url, options: nil, completionHandler: nil)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
      }
      else {
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
      }
      present(alertController, animated: true, completion: nil)
      return
    }
    let publicMessage = PublicMessage(text: text)
    guard let payload = try? publicMessage.serializedData() else { return }
    let message = Message(payloadType: .publicMessage, payload: payload)
    service.receiveMessageSubject.send(message)
    try? service.send(message)
    MessagesViewController.numberOfSentMessages += 1
    if MessagesViewController.numberOfSentMessages == 4 {
      // User is delighted. We will ask for review now.
      SKStoreReviewController.requestReviewForCurrentVersionIfNeeded()
      // Bug workaround for disappearing keyboard after presenting review request alert
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.becomeFirstResponder()
        self.reloadInputViews()
      }
    }
    messageInputView?.textField.resignFirstResponder()
  }
}

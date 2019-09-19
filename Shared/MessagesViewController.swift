//
//  Created by Zsombor Szabo on 19/06/2019.
//  Copyright © 2019 IZE. All rights reserved.
//

import Foundation
import SwiftUI
import BerkananSDK
import StoreKit

class MessagesViewController: UIHostingController<AnyView> {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        if let presentedViewController = self.presentedViewController, !presentedViewController.isBeingDismissed {
            return nil
        }
        return messageInputView
    }
    
    lazy private var messageInputView: MessageInputView? = {
        let view = self.nibBundle?.loadNibNamed("MessageInputView", owner: self, options: nil)?.first as? MessageInputView
        view?.sendButton.addTarget(self, action: #selector(handleTapSendButton), for: .touchUpInside)
        return view
    }()
    
    @objc func handleTapSendButton() {
        guard let payload = messageInputView?.textField.text else { return }
        guard let network = (UIApplication.shared.delegate as? AppDelegate)?.berkananNetwork else { return }
        let status = network.bluetoothAuthorization
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
        let message = PublicBroadcastMessage(text: payload)
        network.publicBroadcastMessageSubject.send(message)
        network.broadcast(message)        
        messageInputView?.textField.resignFirstResponder()
    }
}

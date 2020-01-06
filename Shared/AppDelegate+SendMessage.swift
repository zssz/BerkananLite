//
//  Created by Zsombor Szabo on 02/01/2020.
//  Copyright © 2020 IZE. All rights reserved.
//

import Foundation
import UIKit
import BerkananSDK
import StoreKit

extension AppDelegate {
  
  public func send(_ text: String) {
    let service = berkananBluetoothService
    let status = service.bluetoothAuthorization
    
    guard status == .allowedAlways else {
      let message = (status == .denied) ? NSLocalizedString("Access to Bluetooth denied.", comment: "") : NSLocalizedString("Access to Bluetooth restricted.", comment: "")
      let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
      if status == .denied {
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (action) in
          guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
      }
      else {
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
      }
      (UIApplication.shared.connectedScenes.first { $0.delegate is UIWindowSceneDelegate }?.delegate as? UIWindowSceneDelegate)?.window??.topViewController?.present(alertController, animated: true, completion: nil)
      return
    }
    
    guard self.userData.numberOfNearbyUsers > 0 else {
      showErrorMessage(message: NSLocalizedString("No nearby users.", comment: ""))
      return
    }
    
    guard !self.isMessageTooBig(for: self.userData.composedText) else {
      showErrorMessage(message: NSLocalizedString("Message is too long.", comment: ""))
      return
    }
    
    let publicMessage = PublicMessage(text: text)
    guard let payload = try? publicMessage.serializedData() else { return }
    let message = Message(payloadType: .publicMessage, payload: payload)
    service.receiveMessageSubject.send(message)
    try? service.send(message)
    self.userData.composedText = ""
    
    // StoreKit
    numberOfSentMessages += 1
    if numberOfSentMessages == 4 {
      // User is delighted. We will ask for review now.
      SKStoreReviewController.requestReviewForCurrentVersionIfNeeded()
      // Bug workaround for disappearing keyboard after presenting review request alert
      #if !targetEnvironment(macCatalyst)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        if let rootViewController = (UIApplication.shared.connectedScenes.first { $0.delegate is UIWindowSceneDelegate }?.delegate as? UIWindowSceneDelegate)?.window??.rootViewController {
          rootViewController.becomeFirstResponder()
          rootViewController.reloadInputViews()
        }
      }
      #endif
    }
  }
  
  private func showErrorMessage(message: String) {
    let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
    (UIApplication.shared.connectedScenes.first { $0.delegate is UIWindowSceneDelegate }?.delegate as? UIWindowSceneDelegate)?.window??.topViewController?.present(alertController, animated: true, completion: nil)
    return
  }
  
  public func isMessageTooBig(for text: String) -> Bool {
    let publicMessage = PublicMessage(text: text)
    let payload = (try? publicMessage.serializedData()) ?? Data()
    let message = Message(payloadType: .publicMessage, payload: payload)
    let isPDUTooBig = message.isPDUTooBig()
    return isPDUTooBig
  }
}

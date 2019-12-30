//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import UserNotifications
import BerkananSDK
import UIKit

extension AppDelegate {
  
  public func setupNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
      DispatchQueue.main.async {
        self.userData.notificationsAuthorizationStatus = settings.authorizationStatus
      }
    })
  }
  
  public func requestUserNotificationAuthorization(provisional: Bool = true) {
    let options: UNAuthorizationOptions = provisional ? [.alert, .sound, .badge, .provisional] : [.alert, .sound, .badge]
    UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
      self.setupNotificationSettings()
      if !provisional && !granted {
        DispatchQueue.main.async {
          self.showNotificationsDenied()
        }
      }
    })
  }
  
  public func showNotificationsDenied() {
    let message = NSLocalizedString("Access to Notifications denied.", comment: "")
    let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (action) in
      guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }))
    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
    (UIApplication.shared.connectedScenes.first { $0.delegate is UIWindowSceneDelegate }?.delegate as? UIWindowSceneDelegate)?.window??.topViewController?.present(alertController, animated: true, completion: nil)
  }
  
  public func configureCurrentUserNotificationCenter() {
    let center = UNUserNotificationCenter.current()
    
    // IMPORTANT: When exporting for localizations Xcode doesn't look for NSString.localizedUserNotificationString(forKey:, arguments:)). Make sure they are exported also by marking them with NSLocalizedString.
    // _ = NSLocalizedString("Message", comment: "")
    // _ = NSLocalizedString("Send", comment: "")
    // _ = NSLocalizedString("Reply", comment: "")
    // _ = NSLocalizedString("Block", comment: "")
    // _ = NSLocalizedString("%u more messages", comment: "")
    
    let replyAction = UNTextInputNotificationAction(identifier: UNNotificationContent.ActionIdentifier.Reply.rawValue, title: NSString.localizedUserNotificationString(forKey: "Reply", arguments: nil), options: [], textInputButtonTitle: NSString.localizedUserNotificationString(forKey: "Send", arguments: nil), textInputPlaceholder: NSString.localizedUserNotificationString(forKey: "Message", arguments: nil))
    
    let blockAction = UNNotificationAction(identifier: UNNotificationContent.ActionIdentifier.Block.rawValue, title: NSString.localizedUserNotificationString(forKey: "Block", arguments: nil), options: [])
    
    let publicMessageCategory = UNNotificationCategory(identifier: UNNotificationContent.CategoryType.PublicMessage.rawValue, actions: [replyAction, blockAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: NSLocalizedString("%u Messages", comment: "Message, not e-mail."), categorySummaryFormat: NSString.localizedUserNotificationString(forKey: "%u more messages", arguments: nil), options: [.customDismissAction, .hiddenPreviewsShowSubtitle])
    
    center.setNotificationCategories([publicMessageCategory])
    center.delegate = self
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let notification = response.notification
    let category = notification.request.content.categoryIdentifier
    
    switch response.actionIdentifier {
      
      case UNNotificationDefaultActionIdentifier:
        switch category {
          
          case UNNotificationContent.CategoryType.PublicMessage.rawValue:
            if let uuid = UUID(uuidString: notification.request.identifier) {
              self.showPublicMessage(with: uuid)
          }
          
          default: ()
      }
      
      // User dismissed (tapped on X button)
      case UNNotificationDismissActionIdentifier:
        switch category {
          
          case UNNotificationContent.CategoryType.PublicMessage.rawValue:
            UNUserNotificationCenter.current().removeDeliveredNotifications(forCategoryIdentifier: category)
          
          default: ()
      }
      
      case UNNotificationContent.ActionIdentifier.Reply.rawValue:
        switch category {
          
          case UNNotificationContent.CategoryType.PublicMessage.rawValue:
            if let response = response as? UNTextInputNotificationResponse {
              let publicMessage = PublicMessage(text: response.userText)
              do {
                let payload = try publicMessage.serializedData()
                let message = Message(payloadType: .publicMessage, payload: payload)
                try berkananBluetoothService.send(message)
                berkananBluetoothService.receiveMessageSubject.send(message)
              }
              catch {}
          }
          
          default: ()
      }
      
      case UNNotificationContent.ActionIdentifier.Block.rawValue:
        switch category {
          
          case UNNotificationContent.CategoryType.PublicMessage.rawValue:
            if let uuid = UUID(uuidString: notification.request.identifier), let message = self.messageStore.messages.first(where: {$0.identifier.foundationValue() == uuid}) {
              userData.block(user: message.sourceUser)
          }
          
          default: ()
      }
      
      default: ()
    }
    
    completionHandler()
  }
}

extension AppDelegate {
  
  public func showPublicMessage(with uuid: UUID) {
    // TODO: Implement this feature in your app
  }
}

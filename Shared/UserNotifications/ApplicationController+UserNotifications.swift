//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import UserNotifications
import BerkananSDK
#if os(watchOS)
import WatchKit
#else
import UIKit
#endif

extension ApplicationController {
  
  public func configureCurrentUserNotificationCenter() {
    let center = UNUserNotificationCenter.current()
    
    // IMPORTANT: When exporting for localizations Xcode doesn't look for NSString.localizedUserNotificationString(forKey:, arguments:)). Make sure they are exported also by marking them with NSLocalizedString.
    // _ = NSLocalizedString("Message", comment: "")
    // _ = NSLocalizedString("Send", comment: "")
    // _ = NSLocalizedString("Reply", comment: "")
    // _ = NSLocalizedString("Block", comment: "")
    // _ = NSLocalizedString("%u more messages", comment: "")
    
    #if !os(tvOS)
    let replyAction = UNTextInputNotificationAction(identifier: UNNotificationContent.ActionIdentifier.Reply.rawValue, title: NSString.localizedUserNotificationString(forKey: "Reply", arguments: nil), options: [], textInputButtonTitle: NSString.localizedUserNotificationString(forKey: "Send", arguments: nil), textInputPlaceholder: NSString.localizedUserNotificationString(forKey: "Message", arguments: nil))
    
    let blockAction = UNNotificationAction(identifier: UNNotificationContent.ActionIdentifier.Block.rawValue, title: NSString.localizedUserNotificationString(forKey: "Block", arguments: nil), options: [])
    
    #if os(watchOS)
    let publicMessageCategory = UNNotificationCategory(identifier: UNNotificationContent.CategoryType.PublicMessage.rawValue, actions: [replyAction, blockAction], intentIdentifiers: [], options: [.customDismissAction])
    #else
    let publicMessageCategory = UNNotificationCategory(identifier: UNNotificationContent.CategoryType.PublicMessage.rawValue, actions: [replyAction, blockAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: NSLocalizedString("%u Messages", comment: "Message, not e-mail."), categorySummaryFormat: NSString.localizedUserNotificationString(forKey: "%u more messages", arguments: nil), options: [.customDismissAction, .hiddenPreviewsShowSubtitle])
    #endif
    
    center.setNotificationCategories([publicMessageCategory])
    #endif
    center.delegate = self
  }
  
  public func postUserNotificationIfNeeded(for publicMessage: PublicMessage) {
    // Notify user if needed
    // Only post notification if the app is in the background
    #if os(watchOS)
    guard WKExtension.shared().applicationState == .background else { return }
    #elseif !targetEnvironment(macCatalyst)
    guard UIApplication.shared.applicationState == .background else { return }
    #endif
    // Don't post notification for messages sent by current user
    guard publicMessage.sourceUser.identifier != User.current.identifier else { return }
    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
      DispatchQueue.main.async {
        self.userData.notificationsAuthorizationStatus = settings.authorizationStatus
        // Don't post notification if user can't see it
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
        // Don't post if not enabled
        if settings.authorizationStatus == .authorized && !self.userData.notificationsEnabled {
          return
        }
        UNUserNotificationCenter.current().add(UNNotificationRequest(publicMessage: publicMessage), withCompletionHandler: nil)
      }
    })
  }
  
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
          self.present(error: ApplicationError.notificationsPermissionDenied as NSError)
        }
      }
    })
  }  
}

extension ApplicationController: UNUserNotificationCenterDelegate {
  
  public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
  
  #if !os(tvOS)
  public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
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
                try self.berkananBluetoothService.send(message)
                self.berkananBluetoothService.receiveMessageSubject.send(message)
              }
              catch {}
          }
          
          default: ()
      }
      
      case UNNotificationContent.ActionIdentifier.Block.rawValue:
        switch category {
          
          case UNNotificationContent.CategoryType.PublicMessage.rawValue:
            if let uuid = UUID(uuidString: notification.request.identifier), let message = self.messageStore.messages.first(where: {$0.identifier.foundationValue() == uuid}) {
              self.userData.block(user: message.sourceUser)
          }
          
          default: ()
      }
      
      default: ()
    }
    
    completionHandler()
  }
  #endif
}

extension ApplicationController {
  
  public func showPublicMessage(with uuid: UUID) {
    // TODO: Implement this feature in your app
  }
}

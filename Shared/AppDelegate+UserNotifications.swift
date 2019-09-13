//
//  Created by Zsombor Szabo on 19/06/2019.
//  Copyright © 2019 IZE. All rights reserved.
//

import Foundation
import UserNotifications
import BerkananSDK

extension AppDelegate {
    
    public func setupNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            DispatchQueue.main.async {
                self.userData.showAllowNotificationsButton = (settings.authorizationStatus == .provisional)
            }
        })
    }
    
    public func requestUserNotificationAuthorization(provisional: Bool = true) {
        let options: UNAuthorizationOptions = provisional ? [.alert, .sound, .badge, .provisional] : [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
            self.setupNotificationSettings()
        })
    }
    
    public func configureCurrentUserNotificationCenter() {
        let center = UNUserNotificationCenter.current()
        
        // IMPORTANT: When exporting for localizations Xcode doesn't look for NSString.localizedUserNotificationString(forKey:, arguments:)). Make sure they are exported also by marking them with NSLocalizedString.
        // _ = NSLocalizedString("Message", comment: "")
        // _ = NSLocalizedString("Send", comment: "")
        // _ = NSLocalizedString("Reply", comment: "")
        // _ = NSLocalizedString("%u more messages", comment: "")
        
        let replyAction = UNTextInputNotificationAction(identifier: UNNotificationContent.ActionIdentifier.Reply.rawValue, title: NSString.localizedUserNotificationString(forKey: "Reply", arguments: nil), options: [], textInputButtonTitle: NSString.localizedUserNotificationString(forKey: "Send", arguments: nil), textInputPlaceholder: NSString.localizedUserNotificationString(forKey: "Message", arguments: nil))
        
        let publicBroadcastMessageCategory = UNNotificationCategory(identifier: UNNotificationContent.CategoryType.PublicBroadcastMessage.rawValue, actions: [replyAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: NSLocalizedString("%u Messages", comment: "Message, not e-mail."), categorySummaryFormat: NSString.localizedUserNotificationString(forKey: "%u more messages", arguments: nil), options: [.customDismissAction, .hiddenPreviewsShowSubtitle])
        
        center.setNotificationCategories([publicBroadcastMessageCategory])
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
                
            case UNNotificationContent.CategoryType.PublicBroadcastMessage.rawValue:
                if let uuid = UUID(uuidString: notification.request.identifier) {
                    self.showPublicBroadcastMessage(with: uuid)
                }
                
            default: ()
            }
            
        // User dismissed (tapped on X button)
        case UNNotificationDismissActionIdentifier:
            switch category {
                
            case UNNotificationContent.CategoryType.PublicBroadcastMessage.rawValue:
                UNUserNotificationCenter.current().removeDeliveredNotifications(forCategoryIdentifier: category)
                
            default: ()
            }
            
        case UNNotificationContent.ActionIdentifier.Reply.rawValue:
            switch category {
                
            case UNNotificationContent.CategoryType.PublicBroadcastMessage.rawValue:
                if let response = response as? UNTextInputNotificationResponse {
                    let message = PublicBroadcastMessage(text: response.userText)
                    berkananNetwork.publicBroadcastMessageSubject.send(message)
                    berkananNetwork.broadcast(message)
                }
                
            default: ()
            }
            
        default: ()
        }
        
        completionHandler()
    }
}

extension AppDelegate {
    
    public func showPublicBroadcastMessage(with uuid: UUID) {
        // TODO: Implement this feature in your app
    }
}

//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation

#if canImport(UserNotifications)
import UserNotifications
import BerkananSDK

@available(iOS 10.0, OSX 10.14, *)
extension UNNotificationRequest {
  
  public convenience init(
    publicMessage message: PublicMessage
  ) {
    let notificationContent = UNMutableNotificationContent()
    #if !os(tvOS)
    notificationContent.categoryIdentifier =
      UNNotificationContent.CategoryType.PublicMessage.rawValue
    notificationContent.title = message.sourceUser.displayName
    notificationContent.subtitle = NSLocalizedString("Public", comment: "")
    notificationContent.body = message.text
    #endif
    self.init(
      identifier: message.identifier.foundationValue()?.uuidString ?? "",
      content: notificationContent,
      trigger: UNTimeIntervalNotificationTrigger(
        timeInterval: 0.01,
        repeats: false
    ))
  }
}
#endif

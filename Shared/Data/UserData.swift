//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import BerkananSDK

final class UserData: ObservableObject  {
  
  @Published(key: "firstRun")
  var firstRun: Bool = true
  
  static let minimumBodyFontSize: CGFloat = 17
  
  @Published(key: "bodyFontSize")
  var bodyFontSize: CGFloat = minimumBodyFontSize {
    didSet {
      captionFontSize = floor(bodyFontSize * 12 / 17)
      footnoteFontSize = floor(bodyFontSize * 13 / 17)
    }
  }
  
  @Published(key: "captionFontSize")
  var captionFontSize: CGFloat = 12
  
  @Published(key: "footnoteFontSize")
  var footnoteFontSize: CGFloat = 13
  
  @Published
  var numberOfNearbyUsers: Int = 0
  
  // TODO: remove this when `Text` will get clickable links
  var maxWidth: CGFloat = 0
  
  @Published
  var showsPreferences = false
  
  @Published(key: "composedText")
  var composedText = ""
  
  @Published(key: "termsNotAccepted")
  var termsNotAccepted: Bool = true {
    didSet {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      if !appDelegate.berkananBluetoothService.isStarted {
        appDelegate.berkananBluetoothService.start()
      }
    }
  }
  
  @Published(key: "termsAcceptButtonTapped")
  var termsAcceptButtonTapped: Bool = false {
    didSet {
      if termsAcceptButtonTapped {
        termsNotAccepted = false
      }
    }
  }
  
  @Published(key: "notificationsEnabled")
  var notificationsEnabled: Bool = false {
    didSet {
      if notificationsEnabled {
        (UIApplication.shared.delegate as? AppDelegate)?.requestUserNotificationAuthorization(provisional: false)
      }
    }
  }
  
  @Published
  var notificationsAuthorizationStatus: UNAuthorizationStatus = .notDetermined {
    didSet {
      if notificationsAuthorizationStatus != .authorized {
        notificationsEnabled = false
      }
    }
  }
  
  @Published(key: "showFlaggedMessagesEnabled")
  var showFlaggedMessagesEnabled: Bool = true
  
  @Published(key: "currentUserName")
  var currentUserName: String = UIDevice.current.name {
    didSet {
      User.current.name = currentUserName
      if currentUserName == "Anonymous" {
        currentUserName = ""
      }
    }
  }
  
  @Published(key: "currentUserUUIDString")
  var currentUserUUIDString: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString {
    didSet {
      guard let uuid = UUID(uuidString: currentUserUUIDString) else { return }
      User.current.identifier = uuid.protobufValue()
    }
  }
  
  @Published(key: "blockedUserUUIDs")
  var blockedUserUUIDs: [String] = []
  
  public func isBlocked(user: User) -> Bool {
    guard let uuidString = user.identifier.foundationValue()?.uuidString else { return false }
    return blockedUserUUIDs.contains(uuidString)
  }
  
  public func block(user: User) {
    guard let uuidString = user.identifier.foundationValue()?.uuidString else { return }
    if !blockedUserUUIDs.contains(uuidString) {
      blockedUserUUIDs.append(uuidString)
    }
  }
  
  public func unblock(user: User) {
    guard let uuidString = user.identifier.foundationValue()?.uuidString else { return }
    blockedUserUUIDs.removeAll(where: {$0 == uuidString})
  }
  
  @Published(key: "flaggedMessageUUIDs")
  var flaggedMessageUUIDs: [String] = []
  
  public func isFlagged(message: PublicMessage) -> Bool {
    guard let uuidString = message.identifier.foundationValue()?.uuidString else { return false }
    return flaggedMessageUUIDs.contains(uuidString)
  }
  
  public func flag(message: PublicMessage) {
    guard let uuidString = message.identifier.foundationValue()?.uuidString else { return }
    if !flaggedMessageUUIDs.contains(uuidString) {
      flaggedMessageUUIDs.append(uuidString)
    }
  }
  
  public func unflag(message: PublicMessage) {
    guard let uuidString = message.identifier.foundationValue()?.uuidString else { return }
    flaggedMessageUUIDs.removeAll(where: {$0 == uuidString})
  }
}

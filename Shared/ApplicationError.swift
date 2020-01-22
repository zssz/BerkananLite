//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation

public enum ApplicationError: Int, Error {
  case bluetoothPermissionDenied
  case bluetoothPermissionRestricted
  case notificationsPermissionDenied
  case noNearbyUsers
  case messageTooLong
}

extension ApplicationError: LocalizedError {
  public var errorDescription: String? {
    let bundle = Bundle.main
    switch self {
      case .bluetoothPermissionDenied: return NSLocalizedString("Access to Bluetooth denied", bundle: bundle, comment: "")
      case .bluetoothPermissionRestricted: return NSLocalizedString("Access to Bluetooth restricted", bundle: bundle, comment: "")
      case .notificationsPermissionDenied: return NSLocalizedString("Access to Notifications denied", bundle: bundle, comment: "")
      case .noNearbyUsers: return NSLocalizedString("No nearby users", bundle: bundle, comment: "")
      case .messageTooLong: return NSLocalizedString("Message too long", bundle: bundle, comment: "")
      //default: return nil
    }
  }
}

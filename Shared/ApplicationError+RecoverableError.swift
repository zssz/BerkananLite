//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import UIKit

extension ApplicationError: RecoverableError {
  
  public func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
    switch self {
      case .bluetoothPermissionDenied,
           .notificationsPermissionDenied:
        if recoveryOptionIndex == 0, let url = URL(string: UIApplication.openSettingsURLString) {
          #if AppExtension
          #else
          UIApplication.shared.connectedScenes.first { $0.session.role == .windowApplication }?.open(url, options: nil, completionHandler: nil)
          #endif
          return true
      }
      default: ()
    }
    return false
  }
  
  public var recoveryOptions: [String] {
    switch self {
      case .bluetoothPermissionDenied,
           .notificationsPermissionDenied:
        return [NSLocalizedString("Settings", comment: "")]
      default: return []
    }
  }
}

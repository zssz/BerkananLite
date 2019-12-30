//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import UIKit

extension UIWindow {
  
  public var topViewController: UIViewController? {
    if var viewController = self.rootViewController {
      while viewController.presentedViewController != nil {
        viewController = viewController.presentedViewController!
      }
      return viewController
    }
    return nil
  }
}

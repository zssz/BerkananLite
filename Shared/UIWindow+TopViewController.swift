//
//  Created by Zsombor Szabo on 18/09/2019.
//  Copyright © 2019 IZE. All rights reserved.
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

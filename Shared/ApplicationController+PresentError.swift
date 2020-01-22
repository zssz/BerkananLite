//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
#if os(watchOS)
import WatchKit
#else
import UIKit
#endif

extension ApplicationController {
  
  public func present(error: NSError) {
    #if os(watchOS)
    WKExtension.shared().visibleInterfaceController?.presentAlert(withTitle: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert, actions: [WKAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { })])
    #else
    (UIApplication.shared.connectedScenes.first { $0.delegate is UIWindowSceneDelegate }?.delegate as? UIWindowSceneDelegate)?.window??.topViewController?.present(error as NSError, animated: true)
    #endif
  }
}

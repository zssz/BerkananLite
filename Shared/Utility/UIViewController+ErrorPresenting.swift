//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import UIKit

extension UIViewController {
  
  func present(_ errorToPresent: NSError, title: String? = NSLocalizedString("Error", comment: ""), swapTitleAndMessage swapFlag: Bool = false, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
    var messages = [String]()
    messages.append(errorToPresent.localizedDescription)
    if let suggestion = errorToPresent.localizedRecoverySuggestion {
      messages.append(suggestion)
    }
    let message = messages.joined(separator: "\n")
    
    let alertController = UIAlertController(title: swapFlag ? message : title, message: swapFlag ? title : message, preferredStyle: .alert)
    if let options = errorToPresent.localizedRecoveryOptions, !options.isEmpty, let recoveryAttempter = errorToPresent.recoveryAttempter {
      for (index, option) in options.enumerated() {
        let action = UIAlertAction(title: option, style: .default, handler: { (action) in
          _ = (recoveryAttempter as AnyObject).attemptRecovery(fromError: errorToPresent, optionIndex: index)
        })
        alertController.addAction(action)
      }
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
    }
    else {
      alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
    }
    
    present(alertController, animated: flag, completion: completion)
  }
  
}

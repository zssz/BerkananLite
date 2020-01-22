//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import StoreKit

#if !os(tvOS)
extension SKStoreReviewController {
  
  open class func requestReviewForCurrentVersionIfNeeded() {
    // Get the current bundle version for the app
    let infoDictionaryKey = kCFBundleVersionKey as String
    guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
      else { fatalError("Expected to find a bundle version in the info dictionary") }
    
    let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersionPromptedForReview")
    
    // Has the user has not already been prompted for this version?
    if currentVersion != lastVersionPromptedForReview {
      SKStoreReviewController.requestReview()
      UserDefaults.standard.set(currentVersion, forKey: "lastVersionPromptedForReview")
    }
  }
}
#endif

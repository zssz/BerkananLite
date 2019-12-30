//
//  Created by Zsombor Szabo on 06/10/2018.
//  Copyright © 2018 IZE. All rights reserved.
//

import Foundation
import StoreKit

extension SKStoreReviewController {
  
  open class func requestReviewForCurrentVersionIfNeeded() {
    // Get the current bundle version for the app
    let infoDictionaryKey = kCFBundleVersionKey as String
    guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
      else { fatalError("Expected to find a bundle version in the info dictionary") }
    
    let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersionPromptedForReview")
    
    // Has the user has not already been prompted for this version?
//    if currentVersion != lastVersionPromptedForReview {
      SKStoreReviewController.requestReview()
      UserDefaults.standard.set(currentVersion, forKey: "lastVersionPromptedForReview")
//    }
  }
}


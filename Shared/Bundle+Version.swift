//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation

extension Bundle {
  
  public var shortVersion: String {
    return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
  }
  
  public var bundleVersion: String {
    return object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
  }
  
  public var formattedVersion: String {
    return shortVersion + " (" + bundleVersion + ")"
  }
}

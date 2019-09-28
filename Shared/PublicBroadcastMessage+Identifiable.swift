//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import BerkananSDK

extension PublicBroadcastMessage: Identifiable {
  
  public var id: UUID? {
    return uuid
  }    
}

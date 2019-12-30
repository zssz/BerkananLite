//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import Combine

extension Published {
  init(wrappedValue defaultValue: Value, key: String) {
    let value = UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
    self.init(initialValue: value)
    projectedValue.receive(subscriber: Subscribers.Sink(receiveCompletion: { (_) in
      ()
    }, receiveValue: { (value) in
      UserDefaults.standard.set(value, forKey: key)
    }))
  }
}

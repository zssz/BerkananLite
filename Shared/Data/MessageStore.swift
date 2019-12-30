//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import SwiftUI
import Combine
import BerkananSDK

class MessageStore : ObservableObject {
  
  private static let maxNumberOfMessages: Int = 1024
  
  @Published var messages: [PublicMessage] = []
  
  init(messages: [PublicMessage] = []) {
    self.messages = messages
  }
  
  public func clear() {
    self.messages = []
  }
  
  public func insert(message: PublicMessage, at index: Int) {
    if self.messages.count >= MessageStore.maxNumberOfMessages {
      self.messages.remove(at: self.messages.count-1)
    }
    self.messages.insert(message, at: index)
  }
  
  public func remove(at offsets: IndexSet) {
    offsets.reversed().forEach { index in
      self.messages.remove(at: index)
    }        
  }
}

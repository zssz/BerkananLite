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
  
  private static let maxNumbferOfMessages: Int = 1024
  
  @Published var messages: [PublicBroadcastMessage] = []
  
  init(messages: [PublicBroadcastMessage] = []) {
    self.messages = messages
  }
  
  public func clear() {
    self.messages = []
  }
  
  public func insert(message: PublicBroadcastMessage, at index: Int) {
    if self.messages.count >= MessageStore.maxNumbferOfMessages {
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

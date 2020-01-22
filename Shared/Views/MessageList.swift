//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI
import BerkananSDK
#if os(watchOS)
import WatchKit
#endif

struct MessageList : View {
  
  @EnvironmentObject var userData: UserData
  
  @ObservedObject var messageStore: MessageStore
  
  var body: some View {
    List {
      #if os(watchOS)
      Button(action: {
        WKExtension.shared().visibleInterfaceController?.presentTextInputController(withSuggestions: self.userData.textInputSuggestion.isEmpty ? nil : [self.userData.textInputSuggestion], allowedInputMode: .allowEmoji, completion: { (results) in
          guard let results = results, let text = results.first as? String else {
            return
          }
          self.userData.textInputSuggestion = text
          ApplicationController.shared.send(text)
        })
      }) {
        HStack {
          Image(systemName: "square.and.pencil")
          Text("New Message")
        }
      }
      #endif
      ForEach(self.messageStore.messages) { message in
        // Don't show messages from blocked users
        if !self.userData.isBlocked(user: message.sourceUser) {
          // Don't show flagged messages if user doesn't want to seem them
          if self.userData.showFlaggedMessagesEnabled ||
            (!self.userData.showFlaggedMessagesEnabled && !self.userData.isFlagged(message: message)) {
            #if os(watchOS)
            NavigationLink(destination: MessageDetail(message: message).environmentObject(self.userData)) {
              MessageRow(message: message).environmentObject(self.userData)
            }.listRowPlatterColor(.clear).listRowInsets(EdgeInsets())
            #elseif os(tvOS)
            MessageRow(message: message).environmentObject(self.userData)
            #else
            MessageRow(message: message).environmentObject(self.userData).contextMenu { MessageActions(message: message).environmentObject(self.userData) }
            #endif
          }
        }
      }.onDelete { indexSet in
        #if os(watchOS)
        withAnimation { self.messageStore.remove(at: indexSet) }
        #else
        self.messageStore.remove(at: indexSet)
        #endif
      }
    }
  }
}

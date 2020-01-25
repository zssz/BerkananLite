//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import SwiftUI
import BerkananSDK
#if os(watchOS)
import WatchKit
#endif

struct MessageActions : View {
  
  @EnvironmentObject var userData: UserData
  @Environment(\.presentationMode) var presentationMode
  
  var message: PublicMessage
  
  var body: some View {
    VStack(alignment: .center) {
      Button(action: {
        #if os(watchOS)
        self.presentationMode.wrappedValue.dismiss()
        #endif
        ApplicationController.shared.send(self.message.text)
      }) {
        HStack {
          Image(systemName: "paperplane")
          Text("Repost")
        }
      }
      if message.sourceUser.identifier != User.current.identifier {
        if self.userData.isFlagged(message: message) {
          Button(action: {
            #if os(watchOS)
            self.presentationMode.wrappedValue.dismiss()
            #endif
            self.userData.unflag(message: self.message)
          }) {
            HStack {
              Image(systemName: "flag.slash")
              Text("Unflag")
            }
          }
        }
        else {
          Button(action: {
            #if os(watchOS)
            self.presentationMode.wrappedValue.dismiss()
            #endif
            self.userData.flag(message: self.message)
          }) {
            HStack {
              Image(systemName: "flag")
              Text("Flag")
            }
          }
        }
        Button(action: {
          #if os(watchOS)
          self.presentationMode.wrappedValue.dismiss()
          #endif
          self.userData.block(user: self.message.sourceUser)
        }) {
          HStack {
            Image(systemName: "hand.raised")
            Text("Block")            
          }
        }
      }
    }
  }
}

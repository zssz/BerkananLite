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
  
  var message: PublicMessage
  
  var body: some View {
    VStack(alignment: .leading) {
      Button(action: {
        ApplicationController.shared.send(self.message.text)
        #if os(watchOS)
        WKExtension.shared().visibleInterfaceController?.pop()
        #endif
      }) {
        HStack {
          Image(systemName: "paperplane")
          Text("Resend")
        }
      }
      if message.sourceUser.identifier != User.current.identifier {
        if self.userData.isFlagged(message: message) {
          Button(action: {
            self.userData.unflag(message: self.message)
            #if os(watchOS)
            WKExtension.shared().visibleInterfaceController?.pop()
            #endif
          }) {
            HStack {
              Image(systemName: "flag.slash")
              Text("Unflag")
            }
          }
        }
        else {
          Button(action: {
            self.userData.flag(message: self.message)
            #if os(watchOS)
            WKExtension.shared().visibleInterfaceController?.pop()
            #endif
          }) {
            HStack {
              Image(systemName: "flag")
              Text("Flag")
            }
          }
        }
        Button(action: {
          self.userData.block(user: self.message.sourceUser)
          #if os(watchOS)
          WKExtension.shared().visibleInterfaceController?.pop()
          #endif
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

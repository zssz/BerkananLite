//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import SwiftUI

struct ContentView: View {
  
  @EnvironmentObject var userData: UserData
  
  @ObservedObject var messageStore: MessageStore
  
  @State var showsBlockedUsersView = false
  
  var body: some View {
    VStack {
      MessageList(messageStore: self.messageStore).environmentObject(self.userData)
        .sheet(isPresented: self.$userData.termsNotAccepted) {
          VStack {
            ScrollView(.vertical) {
              VStack(alignment: .leading) {
                Text("Be a good person. Please don't post objectionable content and don't be abusive.")
                Spacer()
                Text(verbatim: "https://berkanan.chat/terms-lite")
              }
            }
            Button(action: { self.userData.termsAcceptButtonTapped = true }) {
              Text("Accept")
            }
          }.navigationBarTitle(Text("Terms of Use"))
      }
    }
    .contextMenu {
      Button(action: { self.userData.showsPreferences.toggle() }) {
        VStack {
          Image(systemName: "gear").font(.title)
          Text("Settings")
        }
      }.sheet(isPresented: self.$userData.showsPreferences) { SettingsView().environmentObject(self.userData).navigationBarTitle(Text("Dismiss"))
      }
      Button(action: { self.showsBlockedUsersView.toggle() }) {
        VStack {
          Image(systemName: "hand.raised").font(.title)
          Text("Blocked Users")
        }
      }.sheet(isPresented: self.$showsBlockedUsersView) { BlockedUsersView().environmentObject(self.userData).navigationBarTitle(Text("Dismiss"))
      }
    }
    .navigationBarTitle(Text("Public") + Text(verbatim: " ") + Text(verbatim: "(\(self.$userData.numberOfNearbyUsers.wrappedValue))"))
  }  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(messageStore: MessageStore()).environmentObject(UserData())
  }
}

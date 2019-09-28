//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI
import BerkananSDK

struct ContentView : View {
  
  @EnvironmentObject var userData: UserData
  
  @ObservedObject var messageStore: MessageStore
  
  @State var showsInfo = false
  
  @State var showsSettings = false
  
  var body: some View {
    NavigationView {
      self.messagesView.navigationBarTitle(Text("Public")).navigationBarItems(
        leading: Button(action: {
          self.showsInfo = true
        }, label: { Image(systemName: "info.circle").font(.system(size: .init(integerLiteral: 17))).imageScale(.large).padding(5) }).alert(isPresented: $showsInfo) {
          Alert(title: Text("About"), message: Text("📢 Broadcast messages to the crowd around you. The range is about 70 meters, but your messages can reach further because they are retransmitted by receiving apps.\n\n🚨 We believe this service is essential, especially in emergencies. It's enabled by apps joining forces using BerkananSDK.\n\n#berkanansdk #opensource #bluetooth #offline #network #public #broadcast #text #message #messaging #chat #crowd #nearby #background #privacy #noaccount #anonymous"), primaryButton: .cancel(), secondaryButton: .default(Text("Learn More"), action: {
            guard let url = URL(string: "https://github.com/zssz/BerkananSDK") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }))
        }, trailing: Button(action: { self.showsSettings = true }, label: { Image(systemName: "gear").font(.system(size: .init(integerLiteral: 17))).imageScale(.large).padding(5) }
      )).sheet(isPresented: $showsSettings) {
        self.settingsView
      }
    }.navigationViewStyle(StackNavigationViewStyle()).sheet(isPresented: $userData.termsNotAccepted) {
      self.termsView
    }
  }
  
  private var messagesView: some View {
    List {
      ForEach(messageStore.messages) { message in
        // Don't show messages from blocked users
        if !self.userData.isBlocked(user: message.sourceUser) {
          // Don't show flagged messages if user doesn't want to seem them
          if self.userData.showFlaggedMessagesEnabled ||
            (!self.userData.showFlaggedMessagesEnabled && !self.userData.isFlagged(message: message)) {
            MessageRow(message: message).contextMenu {
              Button(action: { UIPasteboard.general.string = [message.sourceUser.name, message.text ?? ""].joined(separator: "\n") }) {
                Text("Copy")
                Image(systemName: "doc.on.doc")
              }
              if message.sourceUser != User.current {
                if self.userData.isFlagged(message: message) {
                  Button(action: { self.userData.unflag(message: message) }) {
                    Text("Unflag")
                    Image(systemName: "flag.slash")
                  }
                }
                else {
                  Button(action: { self.userData.flag(message: message) }) {
                    Text("Flag")
                    Image(systemName: "flag")
                  }
                }
                Button(action: { self.userData.block(user: message.sourceUser) }) {
                  Text("Block")
                  Image(systemName: "hand.raised")
                }
              }
            }
          }
        }
      }.onDelete { indexSet in
        self.messageStore.remove(at: indexSet)
      }
    }
  }
  
  private var settingsView: some View {
    NavigationView {
      SettingsView()
        .environmentObject(self.userData)
        .navigationBarItems(leading: Button(action: { self.showsSettings = false }, label: { Image(systemName: "chevron.down").font(.system(size: .init(integerLiteral: 17))).imageScale(.large).padding(5) }))
    }.navigationViewStyle(StackNavigationViewStyle())
  }
  
  private var termsView: some View {
    NavigationView {
      VStack(alignment: .center) {
        TermsView()
        Button(action: {
          self.userData.termsAcceptButtonTapped = true
        }) {
          Text("Accept")
            .fontWeight(.semibold)
            .font(.system(size: .init(integerLiteral: 17)))
            .frame(minWidth: 300, maxWidth: 300)
            .padding()
            .foregroundColor(.white)
            .background(Color.accentColor)
            .cornerRadius(15)
        }.padding()
      }
    }.navigationViewStyle(StackNavigationViewStyle())
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView(messageStore: MessageStore(messages: [PublicBroadcastMessage(text: "Hello!")]) )
  }
}
#endif

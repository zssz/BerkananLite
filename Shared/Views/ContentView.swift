//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI
import BerkananSDK
import Introspect

struct ContentView : View {
  
  @EnvironmentObject var userData: UserData
  
  @ObservedObject var messageStore: MessageStore
  
  var body: some View {
    return NavigationView {
      self.messagesView.navigationBarTitle(Text("Public") + Text(" ") + Text("(\($userData.numberOfNearbyUsers.wrappedValue))")).navigationBarItems(
        trailing: Button(action: { self.userData.showsPreferences = true }, label: { Image(systemName: "gear").imageScale(.large).padding(5) }
      )).sheet(isPresented: self.$userData.showsPreferences) { self.settingsView }
    }.navigationViewStyle(StackNavigationViewStyle()).sheet(isPresented: $userData.termsNotAccepted) { self.termsView }
  }
  
  private var messagesView: some View {
    ZStack(alignment: .bottom) {
      VStack {
        if !self.messageStore.messages.isEmpty {
          List {
            ForEach(self.messageStore.messages) { message in
              // Don't show messages from blocked users
              if !self.userData.isBlocked(user: message.sourceUser) {
                // Don't show flagged messages if user doesn't want to seem them
                if self.userData.showFlaggedMessagesEnabled ||
                  (!self.userData.showFlaggedMessagesEnabled && !self.userData.isFlagged(message: message)) {
                  MessageRow(message: message).environmentObject(self.userData).contextMenu {
                    Button(action: { UIPasteboard.general.string = message.text }) {
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
          }.introspectTableView { (tableView) in
            tableView.separatorStyle = .none
            tableView.contentInset.bottom = 44
            tableView.keyboardDismissMode = .interactive
          }
        }
        else {
          Spacer()
          Text("No Messages").foregroundColor(Color.gray).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
          Spacer()
          Spacer()
        }
      }
      #if targetEnvironment(macCatalyst)
      TextField("Message", text: self.$userData.composedText) {
        AppDelegate.shared?.send(self.userData.composedText)
      }.textFieldStyle(RoundedBorderTextFieldStyle()).foregroundColor((AppDelegate.shared?.isMessageTooBig(for: self.userData.composedText) ?? false) ? .red : .primary).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)).padding(10).background(BlurView(style: .systemChromeMaterial))
      #endif
    }
  }
  
  private var settingsView: some View {
    NavigationView {
      SettingsView()
        .environmentObject(self.userData)
        .navigationBarItems(leading: Button(action: { self.userData.showsPreferences = false }, label: { Image(systemName: "chevron.down").imageScale(.large) }))
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
    ContentView(messageStore: MessageStore(messages: [PublicMessage(text: "Hello!")])).environmentObject(UserData())
  }
}
#endif

//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI
import BerkananSDK
#if os(tvOS) || os(watchOS)
#else
import Introspect
#endif

struct ContentView : View {
  
  @EnvironmentObject var userData: UserData
  
  @ObservedObject var messageStore: MessageStore
  
  var body: some View {
    return NavigationView {
      self.messagesView
        .navigationBarTitle(Text("Public") + Text(verbatim: " ") + Text(verbatim: "(\(self.$userData.numberOfNearbyUsers.wrappedValue))"))
        .navigationBarItems(trailing: Button(action: { self.userData.showsPreferences.toggle() }, label: { Image(systemName: "gear").imageScale(.large).padding(5) }))
        .sheet(isPresented: self.$userData.showsPreferences) { self.settingsView }
    }.navigationViewStyle(StackNavigationViewStyle())
      .sheet(isPresented: self.$userData.termsNotAccepted) { self.termsView }
  }
  
  private var messagesView: some View {
    ZStack(alignment: .bottom) {
      VStack {
        if !self.messageStore.messages.isEmpty {
          #if os(tvOS)
          MessageList(messageStore: self.messageStore).environmentObject(self.userData)
          #else
          MessageList(messageStore: self.messageStore).environmentObject(self.userData)
            .introspectTableView { (tableView) in
              tableView.separatorStyle = .none
              tableView.contentInset.bottom = 44
              tableView.verticalScrollIndicatorInsets.bottom = tableView.contentInset.bottom
              tableView.keyboardDismissMode = .interactive
          }
          #endif
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
        ApplicationController.shared.send(self.userData.composedText)
      }.textFieldStyle(RoundedBorderTextFieldStyle()).foregroundColor((ApplicationController.shared.isMessageTooLong(for: self.userData.composedText)) ? .red : .primary).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)).padding(10).background(BlurView(style: .systemChromeMaterial))
      #endif
    }
  }
  
  private var settingsView: some View {
    NavigationView {
      SettingsView().environmentObject(self.userData).navigationBarItems(leading: Button(action: { self.userData.showsPreferences.toggle() }, label: { Image(systemName: "chevron.down").imageScale(.large) }))
    }.navigationViewStyle(StackNavigationViewStyle())
  }
  
  private var termsView: some View {
    NavigationView {
      VStack(alignment: .center) {
        TermsView()
        Button(action: { self.userData.termsAcceptButtonTapped = true }) {
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

//
//  Created by Zsombor Szabo on 10/06/2019.
//  Copyright © 2019 IZE. All rights reserved.
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
                    // Bug workaround: This fixes the double presentation issue of the alert from a bar button item
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                            self.showsInfo = false
                        }
                    }
                }, label: { Image(systemName: "info.circle").font(.system(size: .init(integerLiteral: 17))).imageScale(.large).padding(5) }).alert(isPresented: $showsInfo) {
                    Alert(title: Text("About"), message: Text("📢 Broadcast messages to the crowd around you. The range is about 70 meters, but your messages can reach further because they are retransmitted by receiving apps.\n\n🚨 We believe this network is essential, especially in emergencies. It's enabled by apps joining forces using Berkanan SDK.\n\n#berkanansdk #opensource #bluetooth #offline #network #public #broadcast #text #messaging #chat #crowds #nearby #background #privacy"), primaryButton: .cancel(), secondaryButton: .default(Text("Learn More"), action: {
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
                if !self.userData.isBlocked(user: message.sourceUser) {
                    MessageRow(message: message).contextMenu {
                        Button(action: { UIPasteboard.general.string = [message.sourceUser.name, message.text ?? ""].joined(separator: "\n") }) {
                            Text("Copy")
                            Image(systemName: "doc.on.doc")
                        }
                        if message.sourceUser != User.current {
                            Button(action: { self.userData.block(user: message.sourceUser) }) {
                                Text("Block")
                                Image(systemName: "hand.raised")
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

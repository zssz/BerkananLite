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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(messageStore.messages, id: \.uuid) { message in
                    MessageRow(message: message)
                }
                .onDelete(perform: delete)
            }
            .navigationBarTitle(Text("Public"))
            .navigationBarItems(
                leading: HStack(content: {
                    if userData.showAllowNotificationsButton {
                        Button(action: {
                            (UIApplication.shared.delegate as? AppDelegate)?.requestUserNotificationAuthorization(provisional: false)
                        }, label: {
                            Image(systemName: "app.badge").font(.system(size: .init(integerLiteral: 17))).imageScale(.large).padding(5)
                        })
                    } else {
                        EmptyView()
                    }
                }),
                trailing: Button(action: {
                    self.showsInfo = true
                }, label: {
                    Image(systemName: "info.circle").font(.system(size: .init(integerLiteral: 17))).imageScale(.large).padding(5) })
                    .alert(isPresented: $showsInfo) {
                        Alert(title: Text("About"), message: Text("📢 Broadcast messages to people around you and see what they're saying. The range for messages is 70 meters, but they can reach further by going through other users' devices.\n\n🚨 We believe this network is essential, especially in emergencies. It's enabled by apps joining forces using Berkanan SDK.\n\n#berkanansdk #opensource #bluetooth #offline #network #public #broadcast #text #messaging #chat #crowds #nearby #background #privacy"), primaryButton: .cancel(), secondaryButton: .default(Text("Learn More"), action: {
                            guard let url = URL(string: "https://github.com/zssz/BerkananSDK") else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }))
                }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func delete(at offsets: IndexSet) {
        self.messageStore.remove(at: offsets)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView(messageStore: MessageStore(messages: [PublicBroadcastMessage(text: "Hello!")]) )
    }
}
#endif

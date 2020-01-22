//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI

struct BlockedUsersView: View {
  
  @EnvironmentObject var userData: UserData
  
  var body: some View {
    VStack {
      if !self.userData.blockedUserUUIDs.isEmpty {
        List {
          ForEach(self.userData.blockedUserUUIDs, id: \.self) { uuid in
            VStack {
              #if os(tvOS) || os(watchOS)
              Text(verbatim: uuid)
              #else
              Text(verbatim: uuid).contextMenu {
                Button(action: { UIPasteboard.general.string = uuid }) {
                  Text("Copy")
                  Image(systemName: "doc.on.doc")
                }
                Button(action: {
                  #if os(watchOS)
                  withAnimation { self.userData.blockedUserUUIDs.removeAll(where: {$0 == uuid}) }
                  #else
                  self.userData.blockedUserUUIDs.removeAll(where: {$0 == uuid})
                  #endif
                }) {
                  Text("Delete")
                  Image(systemName: "trash")
                }
              }
              #endif
            }
          }.onDelete { (indexSet) in
            #if os(watchOS)
            withAnimation { self.userData.blockedUserUUIDs.remove(atOffsets: indexSet) }
            #else
            self.userData.blockedUserUUIDs.remove(atOffsets: indexSet)
            #endif
          }
        }.listStyle(PlainListStyle())
      }
      else {
        Spacer()
        Text("No Users").foregroundColor(.gray).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
        Spacer()
      }
    }.navigationBarTitle(Text("Blocked Users"))
  }
}

struct BlockedUsersView_Previews: PreviewProvider {
  static var previews: some View {
    BlockedUsersView().environmentObject(UserData())
  }
}

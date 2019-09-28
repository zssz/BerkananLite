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
    List {
      ForEach(userData.blockedUserUUIDs, id: \.self) { uuid in
        Text(uuid).contextMenu {
          Button(action: { UIPasteboard.general.string = uuid }) {
            Text("Copy")
            Image(systemName: "doc.on.doc")
          }
          Button(action: { self.userData.blockedUserUUIDs.removeAll(where: {$0 == uuid}) }) {
            Text("Delete")
            Image(systemName: "trash")
          }
        }
      }.onDelete { (indexSet) in
        self.userData.blockedUserUUIDs.remove(atOffsets: indexSet)                
      }
    }.listStyle(PlainListStyle())
      .navigationBarTitle(Text("Blocked Users"))
  }
}

struct BlockedUsersView_Previews: PreviewProvider {
  static var previews: some View {
    BlockedUsersView()
  }
}

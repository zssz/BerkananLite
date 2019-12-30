//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI

struct SettingsView: View {
  
  @EnvironmentObject var userData: UserData
  
  var body: some View {
    Form {
      Section(footer: Text("When turned on, the app icon badge shows the number of nearby users.")) {
        Toggle(isOn: $userData.notificationsEnabled) { Text("Notifications") }
      }
      Section(header: Text("User")) {
        HStack {
          Text("Name")
          Divider()
          TextField("Nameless", text: $userData.currentUserName)
        }
        HStack {
          Text("Identifier")
          Divider()
          Text(userData.currentUserUUIDString).foregroundColor(Color(UIColor.placeholderText)).contextMenu {
            Button(action: { UIPasteboard.general.string = self.userData.currentUserUUIDString }) {
              Text("Copy")
              Image(systemName: "doc.on.doc")
            }
            Button(action: { self.userData.currentUserUUIDString = UUID().uuidString }) {
              Text("Refresh")
              Image(systemName: "arrow.clockwise")
            }
          }
        }
      }
      
      Section {
        NavigationLink(destination: BlockedUsersView().environmentObject(userData)) { Text("Blocked Users") }
        Toggle(isOn: $userData.showFlaggedMessagesEnabled) { Text("Show Flagged Messages") }
      }
      
      Section(header: Text("About"), footer: Text("Version \(Bundle.main.formattedVersion)")) {
        NavigationLink(destination: TermsView()) { Text("Terms of Use") }
        NavigationLink(destination: PrivacyView()) { Text("Privacy Policy") }
        Button(action: {
          guard let url = URL(string: "mailto:support@berkanan.chat?subject=Hello") else { return }
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }) { Text("Contact") }
        Button(action: {
          guard let url = URL(string: "https://github.com/zssz/BerkananLite") else { return }
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }) { Text("View Source Code") }
      }
    }.navigationBarTitle(Text("Settings"))
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}

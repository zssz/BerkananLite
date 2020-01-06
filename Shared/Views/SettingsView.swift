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
      #if targetEnvironment(macCatalyst)
      Section {
        Stepper(onIncrement: {
          self.userData.bodyFontSize += 2
        }, onDecrement: {
          guard self.userData.bodyFontSize > UserData.minimumBodyFontSize else { return }
          self.userData.bodyFontSize -= 2
        }, label: { Text("Font Size").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) })
      }
      #endif
      Section(footer: Text("When turned on, the app icon badge shows the number of nearby users.").modifier(SystemFont(font: .footnote, sizeOnMacCatalyst: self.$userData.footnoteFontSize))) {
        Toggle(isOn: $userData.notificationsEnabled) { Text("Notifications").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
      }
      Section(header: Text("User").modifier(SystemFont(font: .caption, sizeOnMacCatalyst: self.$userData.captionFontSize))) {
        HStack {
          Text("Name").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
          Divider()
          TextField("Nameless", text: $userData.currentUserName).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
        }
        HStack {
          Text("Identifier").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
          Divider()
          Text(userData.currentUserUUIDString).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)).foregroundColor(Color(UIColor.placeholderText)).contextMenu {
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
        NavigationLink(destination: BlockedUsersView().environmentObject(userData)) { Text("Blocked Users").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
        Toggle(isOn: $userData.showFlaggedMessagesEnabled) { Text("Show Flagged Messages").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
      }
      Section(header: Text("About").modifier(SystemFont(font: .caption, sizeOnMacCatalyst: self.$userData.captionFontSize)), footer: Text("Version \(Bundle.main.formattedVersion)").modifier(SystemFont(font: .footnote, sizeOnMacCatalyst: $userData.footnoteFontSize))) {
        NavigationLink(destination: TermsView()) { Text("Terms of Use").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
        NavigationLink(destination: PrivacyView()) { Text("Privacy Policy").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
        Button(action: {
          guard let url = URL(string: "mailto:support@berkanan.chat?subject=Hello") else { return }
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }) { Text("Contact").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
        Button(action: {
          guard let url = URL(string: "https://github.com/zssz/BerkananLite") else { return }
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }) { Text("View Source Code").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
      }
    }.navigationBarTitle(Text("Settings"))
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView().environmentObject(UserData())
  }
}

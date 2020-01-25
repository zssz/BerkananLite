//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI

struct SettingsView: View {
  
  @EnvironmentObject var userData: UserData
  
  @State var showsIDActionSheet = false
  
  var body: some View {
    Form {
      #if targetEnvironment(macCatalyst)
      Section {
        Stepper(onIncrement: {
          self.userData.bodyFontSize += 2
        }, onDecrement: {
          guard self.userData.bodyFontSize > UserData.minimumBodyFontSize else { return }
          self.userData.bodyFontSize -= 2
        }, label: { Text("Text Size").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) })
      }
      #endif
      #if !os(watchOS)
      Section(footer: Text("When turned on, the app icon badge shows the number of nearby users.").modifier(SystemFont(font: .footnote, sizeOnMacCatalyst: self.$userData.footnoteFontSize))) {
        Toggle(isOn: self.$userData.notificationsEnabled) { Text("Notifications").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
      }
      #endif
      Section(header: Text("User").modifier(SystemFont(font: .caption, sizeOnMacCatalyst: self.$userData.captionFontSize))) {
        HStack {
          Text("Name").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
          Divider()
          TextField("Name", text: self.$userData.currentUserName).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
        }
        #if os(tvOS) || os(watchOS)
        Button(action: { self.showsIDActionSheet.toggle() }) {
          HStack {
            Text("ID").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
            Divider()
            Text(verbatim: self.userData.currentUserUUIDString).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
          }
        }.actionSheet(isPresented: self.$showsIDActionSheet) {
          ActionSheet(title: Text("ID"), message: Text(verbatim: self.userData.currentUserUUIDString), buttons: [
            .default(Text("Refresh"), action: { self.userData.currentUserUUIDString = UUID().uuidString}),
            .cancel({ self.showsIDActionSheet = false })
          ])
        }
        #else
        HStack {
          Text("ID").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
          Divider()
          #if os(tvOS) || os(watchOS)
          Text(verbatim: self.userData.currentUserUUIDString).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize))
          #else
          Text(verbatim: self.userData.currentUserUUIDString).modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)).foregroundColor(Color(UIColor.placeholderText)).contextMenu {
            Button(action: { UIPasteboard.general.string = self.userData.currentUserUUIDString }) {
              Text("Copy")
              Image(systemName: "doc.on.doc")
            }
            Button(action: {
              #if os(watchOS)
              withAnimation { self.userData.currentUserUUIDString = UUID().uuidString }
              #else
              self.userData.currentUserUUIDString = UUID().uuidString
              #endif
            }) {
              Text("Refresh")
              Image(systemName: "arrow.clockwise")
            }
          }
          #endif
        }
        #endif
      }
      Section {
        #if !os(watchOS)
        NavigationLink(destination: BlockedUsersView().environmentObject(self.userData)) { Text("Blocked Users").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
        #endif
        Toggle(isOn: self.$userData.showFlaggedMessagesEnabled) { Text("Show Flagged Messages").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
      }
      #if !os(watchOS)
      Section(header: Text("About").modifier(SystemFont(font: .caption, sizeOnMacCatalyst: self.$userData.captionFontSize)), footer: Text("Version \(Bundle.main.formattedVersion)").modifier(SystemFont(font: .footnote, sizeOnMacCatalyst: self.$userData.footnoteFontSize))) {
        NavigationLink(destination: TermsView()) { Text("Terms of Use").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
        NavigationLink(destination: PrivacyView()) { Text("Privacy Policy").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
        #if !os(tvOS)
        Button(action: {
          guard let url = URL(string: "mailto:support@berkanan.chat") else { return }
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }) { Text("Contact").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
        Button(action: {
          guard let url = URL(string: "https://github.com/zssz/BerkananLite") else { return }
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }) { Text("View Source Code").modifier(SystemFont(font: .body, sizeOnMacCatalyst: self.$userData.bodyFontSize)) }
        #endif
      }
      #endif
    }.navigationBarTitle(Text("Settings"))
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView().environmentObject(UserData())
  }
}

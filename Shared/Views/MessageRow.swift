//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI
import BerkananSDK

struct MessageRow : View {
  
  var message: PublicMessage
  
  @EnvironmentObject var userData: UserData
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(verbatim: self.message.sourceUser.displayName).modifier(SystemFont(font: Font.body.weight(.semibold), sizeOnMacCatalyst: self.$userData.bodyFontSize, weight: .semibold, design: .default))
      #if os(watchOS) || os(tvOS)
      Text(verbatim: self.message.text).font(.body)
      #else
      TextView(text: self.message.text, maxWidth: self.$userData.maxWidth, fontSizeOnMacCatalyst: self.$userData.bodyFontSize)
      #endif
    }
  }
}

#if DEBUG
struct MessageRow_Previews : PreviewProvider {
  static var previews: some View {
    Group {
      MessageRow(message: PublicMessage(text: "Hello!")).environmentObject(UserData()).previewLayout(.fixed(width: 300, height: 70))
      MessageRow(message: PublicMessage(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")).environmentObject(UserData()).previewLayout(.fixed(width: 300, height: 70))
    }
  }
}
#endif
